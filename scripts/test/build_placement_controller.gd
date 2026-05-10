class_name BuildPlacementController
extends Node3D

const BuildingPlacementPreviewScript = preload("res://scripts/building/building_placement_preview.gd")

@export var buildable_civil_house_scene: PackedScene
@export var buildable_warehouse_scene: PackedScene
@export var player_path: NodePath = NodePath("../Player")
@export var build_menu_path: NodePath
@export var warehouse_path: NodePath
@export var population_manager_path: NodePath
@export var movement_bounds_min: Vector2 = Vector2(-36.0, -36.0)
@export var movement_bounds_max: Vector2 = Vector2(36.0, 36.0)
@export var placement_distance: float = 80.0
@export var rotation_step_degrees: float = 90.0
@export var footprint_size: Vector3 = Vector3(4.0, 2.0, 4.0)
@export var warehouse_footprint_size: Vector3 = Vector3(4.0, 2.0, 4.0)
@export var civil_house_footprint_size: Vector3 = Vector3(4.0, 2.0, 4.0)
@export var min_distance_from_player: float = 2.0
@export var min_distance_from_existing_buildings: float = 2.0

var _is_placing: bool = false
var _current_rotation_y: float = 0.0
var _current_position: Vector3 = Vector3.ZERO
var _current_is_valid: bool = false
var _current_invalid_reason: String = ""
var _current_building_id: StringName = &""
var _current_display_name: String = ""
var _current_scene: PackedScene = null
var _current_footprint_size: Vector3 = Vector3.ZERO
var _preview: Node3D = null
var _last_reported_reason: String = ""

@onready var _player: Node3D = get_node_or_null(player_path) as Node3D
@onready var _build_menu: Node = get_node_or_null(build_menu_path)


func _ready() -> void:
	_connect_build_menu()


func _process(_delta: float) -> void:
	if not _is_placing:
		return

	_update_current_target()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("build_mode"):
		print("[BuildMode] H pressionado")
		_open_build_menu()
		get_viewport().set_input_as_handled()
		return

	if not _is_placing:
		return

	if event.is_action_pressed("rotate_building"):
		_rotate_preview()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("build_confirm"):
		try_confirm_placement()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_cancel"):
		cancel_placement()
		get_viewport().set_input_as_handled()


func is_placing() -> bool:
	return _is_placing


func begin_civil_house_placement() -> void:
	begin_placement(&"civil_house")


func begin_warehouse_placement() -> void:
	begin_placement(&"warehouse")


func begin_placement(building_id: StringName) -> void:
	if _is_placing:
		return

	var config := _get_building_config(building_id)
	if config.is_empty():
		print("[BuildMode] construção bloqueada: construcao nao configurada")
		push_warning("[BUILD] Construcao nao configurada: %s." % String(building_id))
		return

	_current_building_id = building_id
	_current_display_name = String(config["display_name"])
	_current_scene = config["scene"] as PackedScene
	_current_footprint_size = config["footprint_size"]
	_is_placing = true
	_current_rotation_y = 0.0
	_last_reported_reason = ""
	_preview = BuildingPlacementPreviewScript.new() as Node3D
	_preview.name = "BuildingPlacementPreview"
	_preview.set("footprint_size", _current_footprint_size)
	add_child(_preview)
	_update_current_target()
	print("[BUILD] Posicionamento de %s iniciado." % _current_display_name)


func cancel_placement() -> void:
	if not _is_placing:
		return

	var display_name := _current_display_name
	_clear_preview()
	print("[BUILD] Posicionamento de %s cancelado." % display_name)


func try_confirm_placement() -> bool:
	if not _is_placing:
		return false

	_update_current_target()
	if not _current_is_valid:
		print("[BuildMode] construção bloqueada: %s" % _current_invalid_reason)
		print("[BUILD] Nao foi possivel posicionar %s: %s." % [_current_display_name, _current_invalid_reason])
		return true

	var instance := _current_scene.instantiate()
	var buildable := instance as Node3D
	if buildable == null:
		instance.queue_free()
		print("[BuildMode] construção bloqueada: cena nao instancia Node3D")
		push_warning("[BUILD] Cena de %s nao instancia Node3D." % _current_display_name)
		return true

	get_parent().add_child(buildable)
	buildable.global_transform = _make_target_transform(_current_position)
	_configure_buildable(buildable)
	var display_name := _current_display_name
	_clear_preview()
	print("[BuildMode] construção criada")
	print("[BUILD] %s posicionado para construcao." % display_name)
	return true


func _connect_build_menu() -> void:
	if _build_menu == null:
		return
	if _build_menu.has_signal("build_selected"):
		var selected_callable := Callable(self, "_on_build_menu_build_selected")
		if not _build_menu.is_connected("build_selected", selected_callable):
			_build_menu.connect("build_selected", selected_callable)


func _open_build_menu() -> void:
	if _is_placing:
		return
	if _build_menu != null and _build_menu.has_method("open_menu"):
		_build_menu.call("open_menu")
		print("[BuildMode] menu de construção aberto")
	else:
		print("[BuildMode] menu de construção aberto")
		begin_civil_house_placement()


func _on_build_menu_build_selected(building_id: StringName) -> void:
	print("[BuildMode] construção selecionada: %s" % _get_building_log_name(building_id))
	begin_placement(building_id)


func _get_building_config(building_id: StringName) -> Dictionary:
	match building_id:
		&"warehouse":
			if buildable_warehouse_scene == null:
				return {}
			return {
				"display_name": "Armazém",
				"scene": buildable_warehouse_scene,
				"footprint_size": warehouse_footprint_size,
			}
		&"civil_house":
			if buildable_civil_house_scene == null:
				return {}
			return {
				"display_name": "Casa Civil",
				"scene": buildable_civil_house_scene,
				"footprint_size": civil_house_footprint_size,
			}
	return {}


func _rotate_preview() -> void:
	_current_rotation_y = wrapf(_current_rotation_y + deg_to_rad(rotation_step_degrees), 0.0, TAU)
	_update_current_target()


func _update_current_target() -> void:
	var validation := _validate_current_target()
	_current_is_valid = bool(validation.get("valid", false))
	_current_invalid_reason = String(validation.get("reason", ""))

	if validation.has("position"):
		_current_position = validation["position"]

	if _preview != null:
		_preview.call("set_target_transform", _make_target_transform(_current_position))
		_preview.call("set_valid", _current_is_valid)

	_report_validation_state()


func _validate_current_target() -> Dictionary:
	var result := _raycast_ground()
	if not _is_valid_ground_hit(result):
		return {
			"valid": false,
			"reason": "sem_chao_valido",
		}

	var placement_position: Vector3 = result["position"]
	if not _is_inside_bounds(placement_position):
		return {
			"valid": false,
			"reason": "fora_dos_bounds",
			"position": placement_position,
		}

	var overlap_reason := _get_overlap_invalid_reason(placement_position)
	if not overlap_reason.is_empty():
		return {
			"valid": false,
			"reason": overlap_reason,
			"position": placement_position,
		}

	var distance_reason := _get_distance_invalid_reason(placement_position)
	if not distance_reason.is_empty():
		return {
			"valid": false,
			"reason": distance_reason,
			"position": placement_position,
		}

	return {
		"valid": true,
		"reason": "",
		"position": placement_position,
	}


func _raycast_ground() -> Dictionary:
	var camera := _get_player_camera()
	if camera == null:
		return {}

	var from := camera.global_position
	var to := from + -camera.global_transform.basis.z * placement_distance
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = _get_raycast_exclusions()
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return get_world_3d().direct_space_state.intersect_ray(query)


func _get_player_camera() -> Camera3D:
	if _player != null:
		var player_camera := _player.get_node_or_null("Camera3D") as Camera3D
		if player_camera != null:
			return player_camera

	return get_viewport().get_camera_3d()


func _get_raycast_exclusions() -> Array[RID]:
	var exclusions: Array[RID] = []
	if _player is CollisionObject3D:
		exclusions.append((_player as CollisionObject3D).get_rid())
	return exclusions


func _is_valid_ground_hit(result: Dictionary) -> bool:
	if result.is_empty() or not result.has("position"):
		return false

	var hit_position: Vector3 = result["position"]
	if not hit_position.is_finite():
		return false

	var collider: Variant = result.get("collider")
	if collider is Node:
		var collider_node := collider as Node
		return collider_node.is_in_group("movement_ground") or String(collider_node.name).contains("Ground")

	return false


func _is_inside_bounds(placement_position: Vector3) -> bool:
	return placement_position.x >= movement_bounds_min.x \
		and placement_position.x <= movement_bounds_max.x \
		and placement_position.z >= movement_bounds_min.y \
		and placement_position.z <= movement_bounds_max.y


func _get_overlap_invalid_reason(placement_position: Vector3) -> String:
	var shape := BoxShape3D.new()
	shape.size = _current_footprint_size

	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = _make_target_transform(placement_position)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var hits := get_world_3d().direct_space_state.intersect_shape(query, 16)
	for hit in hits:
		var collider: Variant = hit.get("collider")
		if collider is Node and not _should_ignore_overlap(collider as Node):
			return "sobrepondo %s" % String((collider as Node).name)

	return ""


func _should_ignore_overlap(node: Node) -> bool:
	if node == _preview or (_preview != null and _preview.is_ancestor_of(node)):
		return true
	if node.is_in_group("movement_ground") or String(node.name).contains("Ground"):
		return true
	return false


func _get_distance_invalid_reason(placement_position: Vector3) -> String:
	if min_distance_from_player > 0.0 and _player != null:
		if _horizontal_distance(placement_position, _player.global_position) < min_distance_from_player:
			return "muito_perto_do_player"

	if min_distance_from_existing_buildings <= 0.0:
		return ""

	for node in get_tree().get_nodes_in_group("npc_house"):
		if node is Node3D and _horizontal_distance(placement_position, (node as Node3D).global_position) < min_distance_from_existing_buildings:
			return "muito_perto_de %s" % String(node.name)

	return ""


func _horizontal_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))


func _make_target_transform(placement_position: Vector3) -> Transform3D:
	return Transform3D(Basis(Vector3.UP, _current_rotation_y), placement_position)


func _configure_buildable(buildable: Node3D) -> void:
	var building_site := _find_first_child_of_type(buildable, "BuildingSite") as BuildingSite
	if building_site != null:
		if _current_building_id == &"warehouse":
			building_site.consume_policy = BuildingResourceConsumer.ConsumePolicy.PLAYER_ONLY
		elif _current_building_id == &"civil_house":
			building_site.consume_policy = BuildingResourceConsumer.ConsumePolicy.WAREHOUSE_THEN_PLAYER
			building_site.warehouse_path = _get_warehouse_path_for(building_site)

	if _current_building_id == &"civil_house":
		_configure_buildable_house(buildable)


func _configure_buildable_house(buildable_house: Node3D) -> void:
	var npc_house := _find_first_child_of_type(buildable_house, "NPCHouse") as NPCHouse
	if npc_house != null:
		npc_house.max_spawned_npcs = _get_stress_max_npcs()
		npc_house.spawn_radius = 8.0
		npc_house.population_capacity_bonus = 10
		npc_house.population_manager_path = _get_population_manager_path_for(npc_house)
		var parent := get_parent()
		if parent != null and parent.has_method("_on_house_creation_requested"):
			var creation_callable := Callable(parent, "_on_house_creation_requested")
			if not npc_house.creation_requested.is_connected(creation_callable):
				npc_house.creation_requested.connect(creation_callable)
		if parent != null and parent.has_method("_on_house_npc_created"):
			var created_callable := Callable(parent, "_on_house_npc_created")
			if not npc_house.npc_created.is_connected(created_callable):
				npc_house.npc_created.connect(created_callable)


func _get_warehouse_path_for(from_node: Node) -> NodePath:
	var explicit_path := _make_relative_path(from_node, warehouse_path)
	if not String(explicit_path).is_empty():
		return explicit_path

	var warehouse := _find_first_child_of_type(get_parent(), "Warehouse") as Warehouse
	if warehouse != null:
		return from_node.get_path_to(warehouse)

	return NodePath("")


func _get_population_manager_path_for(from_node: Node) -> NodePath:
	var explicit_path := _make_relative_path(from_node, population_manager_path)
	if not String(explicit_path).is_empty():
		return explicit_path

	var manager := _find_first_child_of_type(get_parent(), "PopulationManager")
	if manager != null:
		return from_node.get_path_to(manager)

	return NodePath("")


func _find_first_child_of_type(root: Node, class_name_to_find: String) -> Node:
	if root == null:
		return null
	for child in root.get_children():
		if _node_matches_type(child, class_name_to_find):
			return child
		var nested := _find_first_child_of_type(child, class_name_to_find)
		if nested != null:
			return nested

	return null


func _node_matches_type(node: Node, class_name_to_find: String) -> bool:
	if class_name_to_find == "BuildingSite" and node is BuildingSite:
		return true
	if class_name_to_find == "NPCHouse" and node is NPCHouse:
		return true
	if class_name_to_find == "PopulationManager" and _is_valid_population_manager(node):
		return true
	if class_name_to_find == "Warehouse" and node is Warehouse:
		return true
	return node.is_class(class_name_to_find) or node.get_class() == class_name_to_find


func _make_relative_path(from_node: Node, target_path: NodePath) -> NodePath:
	var parent := get_parent()
	if parent == null or String(target_path).is_empty():
		return target_path

	var target := parent.get_node_or_null(target_path)
	if target == null:
		return NodePath("")

	return from_node.get_path_to(target)


func _get_stress_max_npcs() -> int:
	var parent := get_parent()
	if parent != null:
		var value: Variant = parent.get("stress_max_npcs")
		if value != null:
			return int(value)
	return 10


func _report_validation_state() -> void:
	var reason := "" if _current_is_valid else _current_invalid_reason
	if reason == _last_reported_reason:
		return

	_last_reported_reason = reason
	if _current_is_valid:
		print("[BuildMode] preview válido")
		print("[BUILD] Local valido para %s." % _current_display_name)
	else:
		print("[BuildMode] preview inválido: %s" % _current_invalid_reason)
		print("[BUILD] Local invalido: %s." % _current_invalid_reason)


func _is_valid_population_manager(node: Variant) -> bool:
	var manager := node as Node
	return manager != null \
		and manager.has_method("register_house") \
		and manager.has_method("can_spawn") \
		and manager.has_method("try_reserve_population") \
		and manager.has_method("release_population")


func _get_building_log_name(building_id: StringName) -> String:
	match building_id:
		&"civil_house":
			return "Casa Civil"
		&"warehouse":
			return "Armazém"
	return String(building_id)


func _clear_preview() -> void:
	_is_placing = false
	_current_is_valid = false
	_current_invalid_reason = ""
	_current_building_id = &""
	_current_display_name = ""
	_current_scene = null
	_current_footprint_size = Vector3.ZERO
	if _preview != null:
		_preview.queue_free()
		_preview = null
