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
@export var max_navigation_snap_distance: float = 1.5
@export var placement_validation_interval: float = 0.08
@export var placement_debug_enabled: bool = false

var _is_placing: bool = false
var _current_rotation_y: float = 0.0
var _current_position: Vector3 = Vector3.ZERO
var _current_is_valid: bool = false
var _current_invalid_reason: String = ""
var _current_invalid_debug: String = ""
var _current_building_id: StringName = &""
var _current_display_name: String = ""
var _current_scene: PackedScene = null
var _current_footprint_size: Vector3 = Vector3.ZERO
var _current_required_resources: Dictionary = {}
var _current_initial_completed_state: bool = false
var _preview: Node3D = null
var _last_reported_reason: String = ""
var _placement_validation_elapsed: float = 0.0
var _last_ground_probe: Dictionary = {}
var _building_scene_config_cache: Dictionary = {}

@onready var _player: Node3D = get_node_or_null(player_path) as Node3D
@onready var _build_menu: Node = get_node_or_null(build_menu_path)


func _ready() -> void:
	add_to_group("build_controller")
	_connect_build_menu()


func _process(delta: float) -> void:
	if not _is_placing:
		return

	_placement_validation_elapsed += delta
	if _placement_validation_elapsed < placement_validation_interval:
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
	_current_required_resources = (config["required_resources"] as Dictionary).duplicate(true)
	_current_initial_completed_state = bool(config["initial_completed_state"])
	_is_placing = true
	_current_rotation_y = 0.0
	_last_reported_reason = ""
	_preview = BuildingPlacementPreviewScript.new() as Node3D
	_preview.name = "BuildingPlacementPreview"
	_preview.set("footprint_size", _current_footprint_size)
	add_child(_preview)
	_placement_validation_elapsed = placement_validation_interval
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
		if placement_debug_enabled and not _current_invalid_debug.is_empty():
			print("[BuildMode] diagnostico: %s" % _current_invalid_debug)
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
			var warehouse_scene_config := _get_cached_scene_building_config(building_id, buildable_warehouse_scene)
			return {
				"display_name": "Armazém",
				"scene": buildable_warehouse_scene,
				"footprint_size": warehouse_footprint_size,
				"required_resources": warehouse_scene_config["required_resources"],
				"initial_completed_state": warehouse_scene_config["initial_completed_state"],
			}
		&"civil_house":
			if buildable_civil_house_scene == null:
				return {}
			var civil_house_scene_config := _get_cached_scene_building_config(building_id, buildable_civil_house_scene)
			return {
				"display_name": "Casa Civil",
				"scene": buildable_civil_house_scene,
				"footprint_size": civil_house_footprint_size,
				"required_resources": civil_house_scene_config["required_resources"],
				"initial_completed_state": civil_house_scene_config["initial_completed_state"],
			}
	return {}


func _get_cached_scene_building_config(building_id: StringName, scene: PackedScene) -> Dictionary:
	if _building_scene_config_cache.has(building_id):
		return (_building_scene_config_cache[building_id] as Dictionary).duplicate(true)

	var config := {
		"required_resources": {},
		"initial_completed_state": false,
	}
	var probe := scene.instantiate()
	var site := _find_first_child_of_type(probe, "BuildingSite") as BuildingSite
	if site != null:
		var required_value: Variant = site.get("required_resources")
		if required_value is Dictionary:
			config["required_resources"] = (required_value as Dictionary).duplicate(true)
		config["initial_completed_state"] = bool(site.get("is_completed"))
	probe.queue_free()
	_building_scene_config_cache[building_id] = config.duplicate(true)
	return config


func _rotate_preview() -> void:
	_current_rotation_y = wrapf(_current_rotation_y + deg_to_rad(rotation_step_degrees), 0.0, TAU)
	_update_current_target()


func _update_current_target() -> void:
	_placement_validation_elapsed = 0.0
	var validation := _validate_current_target()
	_current_is_valid = bool(validation.get("valid", false))
	_current_invalid_reason = String(validation.get("reason", ""))
	_current_invalid_debug = String(validation.get("debug", ""))

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
			"debug": _format_ground_probe_debug(result),
		}

	var placement_position: Vector3 = result["position"]
	if not _is_inside_bounds(placement_position):
		return {
			"valid": false,
			"reason": "fora_dos_bounds",
			"position": placement_position,
		}

	var system_reason := _get_system_invalid_reason()
	if not system_reason.is_empty():
		return {
			"valid": false,
			"reason": system_reason,
			"position": placement_position,
		}

	var building_state_reason := _get_building_state_invalid_reason()
	if not building_state_reason.is_empty():
		return {
			"valid": false,
			"reason": building_state_reason,
			"position": placement_position,
		}

	var navigation_reason := _get_navigation_invalid_reason(placement_position)
	if not navigation_reason.is_empty():
		return {
			"valid": false,
			"reason": navigation_reason,
			"position": placement_position,
		}

	var resource_reason := _get_resource_invalid_reason()
	if not resource_reason.is_empty():
		return {
			"valid": false,
			"reason": resource_reason,
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
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	_last_ground_probe = {
		"from": from,
		"to": to,
		"collision_mask": query.collision_mask,
		"collide_with_areas": query.collide_with_areas,
		"collide_with_bodies": query.collide_with_bodies,
		"hit": not result.is_empty(),
	}
	return result


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


func _format_ground_probe_debug(result: Dictionary) -> String:
	if _last_ground_probe.is_empty():
		return "raycast sem camera/world disponivel"

	var parts: Array[String] = [
		"from=%s" % str(_last_ground_probe.get("from", Vector3.ZERO)),
		"to=%s" % str(_last_ground_probe.get("to", Vector3.ZERO)),
		"mask=%s" % str(_last_ground_probe.get("collision_mask", 0)),
		"areas=%s" % str(_last_ground_probe.get("collide_with_areas", false)),
		"bodies=%s" % str(_last_ground_probe.get("collide_with_bodies", true)),
	]

	if result.is_empty():
		parts.append("hit=none")
		return ", ".join(parts)

	var collider: Variant = result.get("collider")
	var collider_label := str(collider)
	var collider_groups := ""
	if collider is Node:
		var collider_node := collider as Node
		collider_label = "%s (%s)" % [String(collider_node.name), String(collider_node.get_path())]
		collider_groups = str(collider_node.get_groups())

	parts.append("hit=%s" % collider_label)
	parts.append("hit_position=%s" % str(result.get("position", Vector3.ZERO)))
	parts.append("groups=%s" % collider_groups)
	parts.append("movement_ground=%s" % str(collider is Node and (collider as Node).is_in_group("movement_ground")))
	return ", ".join(parts)


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
			var building_site := _find_related_building_site(collider as Node)
			if building_site != null and bool(building_site.get("is_completed")):
				return "construcao ja concluida"
			return "colisao: %s" % String((collider as Node).name)

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


func _get_system_invalid_reason() -> String:
	if _current_scene == null:
		return "build controller ausente"
	if _current_building_id == &"civil_house" and _resolve_warehouse() == null:
		return "warehouse ausente"
	return ""


func _get_building_state_invalid_reason() -> String:
	if _current_scene == null:
		return "build controller ausente"
	if _current_initial_completed_state:
		return "construcao ja concluida"
	return ""


func _get_navigation_invalid_reason(placement_position: Vector3) -> String:
	if not _tree_has_navigation_region():
		return ""
	var map := get_world_3d().get_navigation_map()
	if not map.is_valid():
		return "fora da area navegavel"
	var closest := NavigationServer3D.map_get_closest_point(map, placement_position)
	if not closest.is_finite():
		return "fora da area navegavel"
	if _horizontal_distance(closest, placement_position) > max_navigation_snap_distance:
		return "fora da area navegavel"
	return ""


func _get_resource_invalid_reason() -> String:
	var required := _get_required_resources_for_current_building()
	if required.is_empty():
		return ""
	if _has_resources_available(required):
		return ""
	return "recurso insuficiente"


func _get_required_resources_for_current_building() -> Dictionary:
	if _current_scene == null:
		return {}
	return _current_required_resources.duplicate(true)


func _has_resources_available(required: Dictionary) -> bool:
	var available := {}
	var warehouse := _resolve_warehouse()
	if warehouse != null and warehouse.has_method("get_stock_snapshot"):
		_merge_resource_snapshot(available, warehouse.call("get_stock_snapshot"))
	var inventory := _resolve_player_inventory()
	if inventory != null:
		if inventory.has_method("get_all_resources"):
			_merge_resource_snapshot(available, inventory.call("get_all_resources"))
		elif inventory.has_method("get_all_items"):
			_merge_resource_snapshot(available, inventory.call("get_all_items"))

	for resource_id in required.keys():
		var required_amount := int(required[resource_id])
		var available_amount := int(available.get(StringName(String(resource_id)), 0))
		if available_amount < required_amount:
			return false
	return true


func _merge_resource_snapshot(target: Dictionary, source: Variant) -> void:
	if not (source is Dictionary):
		return
	for resource_id in (source as Dictionary).keys():
		var key := StringName(String(resource_id))
		target[key] = int(target.get(key, 0)) + int((source as Dictionary)[resource_id])


func _resolve_warehouse() -> Warehouse:
	if not String(warehouse_path).is_empty():
		# Resolve relative to self: paths like "../Warehouse" are exported
		# from the BuildPlacementController, not from its parent.
		var explicit := get_node_or_null(warehouse_path)
		if explicit is Warehouse:
			return explicit
		# Fallback: try from parent in case the path was authored differently.
		var parent := get_parent()
		if parent != null:
			var from_parent := parent.get_node_or_null(warehouse_path)
			if from_parent is Warehouse:
				return from_parent
	for node in get_tree().get_nodes_in_group("warehouse"):
		if node is Warehouse:
			return node
	var scan_parent := get_parent()
	return _find_first_child_of_type(scan_parent, "Warehouse") as Warehouse


func _resolve_player_inventory() -> InventoryContainer:
	var parent := get_parent()
	if parent == null:
		return null
	for node in get_tree().get_nodes_in_group("player_inventory"):
		if node is InventoryContainer:
			return node
	var found := _find_first_child_of_type(parent, "InventoryContainer")
	return found as InventoryContainer


func _tree_has_navigation_region() -> bool:
	var scene := get_tree().current_scene
	if scene == null:
		return false
	return _find_navigation_region(scene) != null


func _find_navigation_region(root: Node) -> NavigationRegion3D:
	if root is NavigationRegion3D:
		return root as NavigationRegion3D
	for child in root.get_children():
		var found := _find_navigation_region(child)
		if found != null:
			return found
	return null


func _find_related_building_site(node: Node) -> BuildingSite:
	var current := node
	while current != null:
		if current is BuildingSite:
			return current as BuildingSite
		var nested := _find_first_child_of_type(current, "BuildingSite") as BuildingSite
		if nested != null:
			return nested
		current = current.get_parent()
	return null


func _horizontal_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))


func _make_target_transform(placement_position: Vector3) -> Transform3D:
	return Transform3D(Basis(Vector3.UP, _current_rotation_y), placement_position)


func _configure_buildable(buildable: Node3D) -> void:
	buildable.add_to_group("destroyable_building")
	var building_site := _find_first_child_of_type(buildable, "BuildingSite") as BuildingSite
	if building_site != null:
		building_site.add_to_group("building_site")
		building_site.is_completed = false
		building_site.build_progress = 0.0
		building_site.consume_policy = BuildingResourceConsumer.ConsumePolicy.WAREHOUSE_THEN_PLAYER
		building_site.warehouse_path = _get_warehouse_path_for(building_site)

	if _current_building_id == &"civil_house":
		_configure_buildable_house(buildable)
	elif _current_building_id == &"warehouse":
		_configure_buildable_warehouse(buildable)


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


func _configure_buildable_warehouse(buildable_warehouse: Node3D) -> void:
	var warehouse := _find_first_child_of_type(buildable_warehouse, "Warehouse") as Warehouse
	if warehouse != null:
		warehouse.add_to_group("warehouse")
	var interactable := _find_first_warehouse_interactable(buildable_warehouse)
	if interactable != null:
		interactable.add_to_group("warehouse_interactable")


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


func _find_first_warehouse_interactable(root: Node) -> Node3D:
	if root == null:
		return null
	if root is Node3D and root.has_method("interact") and _has_property(root, "warehouse_path"):
		return root as Node3D
	for child in root.get_children():
		var nested := _find_first_warehouse_interactable(child)
		if nested != null:
			return nested
	return null


func _has_property(node: Object, property_name: String) -> bool:
	for property in node.get_property_list():
		if String(property.get("name", "")) == property_name:
			return true
	return false


func _node_matches_type(node: Node, class_name_to_find: String) -> bool:
	if class_name_to_find == "BuildingSite" and node is BuildingSite:
		return true
	if class_name_to_find == "NPCHouse" and node is NPCHouse:
		return true
	if class_name_to_find == "PopulationManager" and _is_valid_population_manager(node):
		return true
	if class_name_to_find == "Warehouse" and node is Warehouse:
		return true
	if class_name_to_find == "InventoryContainer" and node is InventoryContainer:
		return true
	return node.is_class(class_name_to_find) or node.get_class() == class_name_to_find


func _make_relative_path(from_node: Node, target_path: NodePath) -> NodePath:
	if String(target_path).is_empty():
		return target_path

	# Try resolving relative to self first (paths exported from this node).
	var target := get_node_or_null(target_path)
	if target == null:
		# Fallback: resolve from parent for legacy path authoring.
		var parent := get_parent()
		if parent != null:
			target = parent.get_node_or_null(target_path)
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
		if placement_debug_enabled and not _current_invalid_debug.is_empty():
			print("[BuildMode] diagnostico: %s" % _current_invalid_debug)


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
	_current_invalid_debug = ""
	_current_building_id = &""
	_current_display_name = ""
	_current_scene = null
	_current_footprint_size = Vector3.ZERO
	_current_required_resources.clear()
	_current_initial_completed_state = false
	_placement_validation_elapsed = 0.0
	if _preview != null:
		_preview.queue_free()
		_preview = null
