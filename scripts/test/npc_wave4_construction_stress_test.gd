extends "res://scripts/test/npc_wave4_test.gd"

@export var movement_bounds_min: Vector2 = Vector2(-36.0, -36.0)
@export var movement_bounds_max: Vector2 = Vector2(36.0, 36.0)
@export var stress_max_npcs: int = 10
@export var auto_spawn_npcs_on_ready: int = 0
@export var move_pick_distance: float = 80.0

var _awaiting_move_destination: bool = false
var _move_destination_npc: NPCBase = null
@onready var _build_placement_controller: Node = get_node_or_null("BuildPlacementController")


func _ready() -> void:
	super._ready()
	_configure_stress_houses()
	_auto_spawn_npcs()
	print("[NPC] Cena integrada Wave 4 + construcao pronta. Bounds=%s..%s stress_max=%d auto_spawn=%d." % [
		str(movement_bounds_min),
		str(movement_bounds_max),
		stress_max_npcs,
		auto_spawn_npcs_on_ready,
	])


func _unhandled_input(event: InputEvent) -> void:
	if _build_placement_controller != null \
			and bool(_build_placement_controller.call("is_placing")) \
			and event.is_action_pressed("ui_cancel"):
		_build_placement_controller.call("cancel_placement")
		get_viewport().set_input_as_handled()
		return

	if _awaiting_move_destination and event.is_action_pressed("ui_cancel"):
		_cancel_move_destination_mode()
		get_viewport().set_input_as_handled()
		return

	super._unhandled_input(event)


func _on_menu_move_requested(npc: NPCBase) -> void:
	if not _is_valid_npc(npc):
		return

	_selected_npc = npc
	_begin_move_destination_mode(npc)


func try_consume_player_interact(_actor: Node = null) -> bool:
	if not _awaiting_move_destination:
		return false

	return _try_confirm_move_destination()


func _order_move_forward() -> void:
	if not _has_selected_npc():
		return

	var reference_basis := _player.global_transform.basis if _player != null else global_transform.basis
	var origin := _selected_npc.global_position
	var forward := -reference_basis.z
	forward.y = 0.0
	if forward.length() <= 0.001:
		print("[NPC] Cena de teste: direcao de movimento invalida.")
		return
	forward = forward.normalized()

	var raw_destination := origin + forward * move_distance
	var destination := _clamp_move_destination(raw_destination)
	if not destination.is_equal_approx(raw_destination):
		print("[NPC] Cena de teste: destino de movimento ajustado para permanecer dentro da area segura.")

	_selected_npc.issue_order(NPCOrder.move_to_position(destination, _player))


func _clamp_move_destination(destination: Vector3) -> Vector3:
	var clamped := destination
	clamped.x = clampf(clamped.x, movement_bounds_min.x, movement_bounds_max.x)
	clamped.z = clampf(clamped.z, movement_bounds_min.y, movement_bounds_max.y)
	var reference_npc := _move_destination_npc if _is_valid_npc(_move_destination_npc) else _selected_npc
	if _is_valid_npc(reference_npc):
		clamped.y = reference_npc.global_position.y
	return clamped


func _begin_move_destination_mode(npc: NPCBase) -> void:
	_awaiting_move_destination = true
	_move_destination_npc = npc
	if _command_menu != null:
		_command_menu.close_menu()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("[NPC] Escolha um ponto no chao e pressione Interagir para confirmar o destino.")


func _try_confirm_move_destination() -> bool:
	if not _is_valid_npc(_move_destination_npc):
		_cancel_move_destination_mode()
		return true

	var result := _raycast_move_destination()
	if not _is_valid_move_destination_hit(result):
		print("[NPC] Destino invalido. Mire no chao da area de teste e pressione Interagir novamente.")
		return true

	var raw_destination: Vector3 = result["position"]
	var destination := _clamp_move_destination(raw_destination)
	if not destination.is_equal_approx(raw_destination):
		print("[NPC] Destino de movimento ajustado para permanecer dentro da area segura.")

	_move_destination_npc.issue_order(NPCOrder.move_to_position(destination, _player))
	_finish_move_destination_mode()
	return true


func _raycast_move_destination() -> Dictionary:
	var camera := _get_player_camera()
	if camera == null:
		return {}

	var from := camera.global_position
	var to := from + -camera.global_transform.basis.z * move_pick_distance
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = _get_move_raycast_exclusions()
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return get_world_3d().direct_space_state.intersect_ray(query)


func _get_player_camera() -> Camera3D:
	if _player != null:
		var player_camera := _player.get_node_or_null("Camera3D") as Camera3D
		if player_camera != null:
			return player_camera

	return get_viewport().get_camera_3d()


func _get_move_raycast_exclusions() -> Array[RID]:
	var exclusions: Array[RID] = []
	if _player is CollisionObject3D:
		exclusions.append((_player as CollisionObject3D).get_rid())
	if _move_destination_npc is CollisionObject3D:
		exclusions.append((_move_destination_npc as CollisionObject3D).get_rid())
	return exclusions


func _is_valid_move_destination_hit(result: Dictionary) -> bool:
	if result.is_empty() or not result.has("position"):
		return false

	var target_position: Vector3 = result["position"]
	if not target_position.is_finite():
		return false

	var collider: Variant = result.get("collider")
	if collider is Node:
		var collider_node := collider as Node
		return collider_node.is_in_group("movement_ground") or String(collider_node.name).contains("Ground")

	return false


func _finish_move_destination_mode() -> void:
	_awaiting_move_destination = false
	_move_destination_npc = null


func _cancel_move_destination_mode() -> void:
	if not _awaiting_move_destination:
		return

	_finish_move_destination_mode()
	print("[NPC] Escolha de destino cancelada.")


func _configure_stress_houses() -> void:
	for npc_house in _get_houses():
		npc_house.max_spawned_npcs = stress_max_npcs
		npc_house.population_capacity_bonus = 10


func _auto_spawn_npcs() -> void:
	var requested := clampi(auto_spawn_npcs_on_ready, 0, stress_max_npcs)
	if requested <= 0:
		return

	var houses := _get_houses()
	if houses.is_empty():
		print("[NPC] Cena integrada: auto-spawn ignorado, nenhuma Casa Civil encontrada.")
		return

	var npc_house := houses[0]
	var created := 0
	while created < requested and npc_house.can_create_npc():
		var npc := npc_house.create_npc(_player)
		if npc == null:
			break
		_connect_npc_signal(npc)
		created += 1

	print("[NPC] Cena integrada: auto-spawn criou %d civis para teste de estresse." % created)
