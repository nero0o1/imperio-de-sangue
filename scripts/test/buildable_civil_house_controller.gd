class_name BuildableCivilHouseController
extends Node

@export var building_site_path: NodePath
@export var npc_house_path: NodePath
@export var keep_house_visual_hidden: bool = true
@export var disable_building_site_collision_when_complete: bool = true

var _building_site: BuildingSite = null
var _npc_house: NPCHouse = null
var _civil_house_enabled := false


func _ready() -> void:
	_building_site = get_node_or_null(building_site_path) as BuildingSite
	_npc_house = get_node_or_null(npc_house_path) as NPCHouse

	if _building_site == null:
		push_warning("[NPC] BuildableCivilHouseController sem BuildingSite valido.")
	if _npc_house == null:
		push_warning("[NPC] BuildableCivilHouseController sem NPCHouse valida.")
		return

	_align_house_to_building_site()
	_set_house_enabled(_is_building_completed())

	if _building_site != null and not _building_site.construction_completed.is_connected(_on_construction_completed):
		_building_site.construction_completed.connect(_on_construction_completed)


func is_civil_house_enabled() -> bool:
	return _civil_house_enabled


func _on_construction_completed(building_site: BuildingSite) -> void:
	if building_site != _building_site:
		return

	_set_house_enabled(true)
	print("[NPC] Casa Civil construida. Criacao de civis habilitada.")


func _is_building_completed() -> bool:
	return _building_site != null and is_instance_valid(_building_site) and _building_site.is_completed


func _align_house_to_building_site() -> void:
	if _building_site == null or _npc_house == null:
		return

	var building_position := _building_site.global_position
	building_position.y = 0.0
	_npc_house.global_position = building_position


func _set_house_enabled(enabled: bool) -> void:
	if _npc_house == null or not is_instance_valid(_npc_house):
		return

	_civil_house_enabled = enabled
	_npc_house.creation_enabled = enabled
	_npc_house.visible = not keep_house_visual_hidden and enabled
	_set_collision_enabled(_npc_house, enabled)

	if _building_site != null and disable_building_site_collision_when_complete:
		_set_collision_enabled(_building_site, not enabled)


func _set_collision_enabled(root: Node, enabled: bool) -> void:
	for child in root.get_children():
		if child is CollisionShape3D:
			(child as CollisionShape3D).disabled = not enabled
		_set_collision_enabled(child, enabled)
