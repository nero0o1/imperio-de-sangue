extends Label

@export var player_inventory_path: NodePath
@export var warehouse_path: NodePath
@export var building_site_path: NodePath
@export var update_interval: float = 0.25

var _elapsed := 0.0

# Cache dos nos de dominio. Evita get_node_or_null() a cada tick (0.25s).
var _cached_player_inventory: InventoryContainer = null
var _cached_warehouse: Warehouse = null
var _cached_building_site: BuildingSite = null


func _ready() -> void:
	_cache_domain_nodes()
	_update_text()


func _cache_domain_nodes() -> void:
	if not player_inventory_path.is_empty():
		var node := get_node_or_null(player_inventory_path)
		if node is InventoryContainer:
			_cached_player_inventory = node

	if not warehouse_path.is_empty():
		var node := get_node_or_null(warehouse_path)
		if node is Warehouse:
			_cached_warehouse = node

	if not building_site_path.is_empty():
		var node := get_node_or_null(building_site_path)
		if node is BuildingSite:
			_cached_building_site = node


func _process(delta: float) -> void:
	_elapsed += delta

	if _elapsed < update_interval:
		return

	_elapsed = 0.0
	_update_text()


func _update_text() -> void:
	var player_inventory := _get_player_inventory()
	var warehouse := _get_warehouse()
	var building_site := _get_building_site()

	var lines: Array[String] = [
		"Player Inventory:",
		_format_inventory(player_inventory),
		"",
		"Warehouse:",
		_format_warehouse(warehouse),
		"",
		"Building:",
		_format_building(building_site),
	]

	text = _join_lines(lines)


func _get_player_inventory() -> InventoryContainer:
	if _cached_player_inventory != null and is_instance_valid(_cached_player_inventory):
		return _cached_player_inventory
	return null


func _get_warehouse() -> Warehouse:
	if _cached_warehouse != null and is_instance_valid(_cached_warehouse):
		return _cached_warehouse
	return null


func _get_building_site() -> BuildingSite:
	if _cached_building_site != null and is_instance_valid(_cached_building_site):
		return _cached_building_site
	return null


func _format_inventory(inventory: InventoryContainer) -> String:
	if inventory == null:
		return "nao configurado"

	return _format_items(inventory.get_all_resources())


func _format_warehouse(warehouse: Warehouse) -> String:
	if warehouse == null:
		return "nao configurado"

	return _format_items(warehouse.get_stock_snapshot())


func _format_building(building_site: BuildingSite) -> String:
	if building_site == null:
		return "nao configurado"

	return "Progress: %.0f%%\nCompleted: %s" % [
		building_site.build_progress,
		str(building_site.is_completed),
	]


func _format_items(items: Dictionary) -> String:
	if items.is_empty():
		return "vazio"

	var keys := items.keys()
	keys.sort_custom(func(a, b): return String(a) < String(b))
	var parts: Array[String] = []
	for item_id in keys:
		parts.append("%s: %d" % [String(item_id), int(items[item_id])])

	return _join_lines(parts)


func _join_lines(lines: Array[String], separator: String = "\n") -> String:
	var result := ""

	for line in lines:
		if not result.is_empty():
			result += separator
		result += line

	return result
