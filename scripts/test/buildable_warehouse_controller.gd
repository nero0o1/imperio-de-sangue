class_name BuildableWarehouseController
extends Node

@export var building_site_path: NodePath
@export var warehouse_interactable_path: NodePath
@export var disable_building_site_collision_when_complete: bool = true

var _building_site: BuildingSite = null
var _warehouse_interactable: Node3D = null


func _ready() -> void:
	_building_site = get_node_or_null(building_site_path) as BuildingSite
	_warehouse_interactable = get_node_or_null(warehouse_interactable_path) as Node3D

	if _building_site == null:
		push_warning("[BUILD] BuildableWarehouseController sem BuildingSite valido.")
	if _warehouse_interactable == null:
		push_warning("[BUILD] BuildableWarehouseController sem WarehouseInteractable valido.")

	_set_warehouse_enabled(_is_building_completed())

	if _building_site != null and not _building_site.construction_completed.is_connected(_on_construction_completed):
		_building_site.construction_completed.connect(_on_construction_completed)


func _on_construction_completed(building_site: BuildingSite) -> void:
	if building_site != _building_site:
		return

	_set_warehouse_enabled(true)
	print("[BUILD] Armazem construido. Interacao com armazem habilitada.")


func _is_building_completed() -> bool:
	return _building_site != null and is_instance_valid(_building_site) and _building_site.is_completed


func _set_warehouse_enabled(enabled: bool) -> void:
	if _warehouse_interactable != null and is_instance_valid(_warehouse_interactable):
		_warehouse_interactable.visible = enabled
		_set_collision_enabled(_warehouse_interactable, enabled)

	if _building_site != null and disable_building_site_collision_when_complete:
		_set_collision_enabled(_building_site, not enabled)


func _set_collision_enabled(root: Node, enabled: bool) -> void:
	for child in root.get_children():
		if child is CollisionShape3D:
			(child as CollisionShape3D).disabled = not enabled
		_set_collision_enabled(child, enabled)
