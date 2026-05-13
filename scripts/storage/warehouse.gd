class_name Warehouse
extends Node

@export var warehouse_id: StringName = &"warehouse_default"
@export var settlement_id: StringName = &"settlement_default"
@export var capacity_limit: int = -1

var stock: Dictionary = {}
var inventory: InventoryContainer
var _syncing_inventory := false

signal warehouse_changed(warehouse_id: StringName)


func _ready() -> void:
	add_to_group("warehouse")
	ensure_inventory()
	_sync_inventory_from_stock()


func deposit(item_id: StringName, quantity: int) -> int:
	if String(item_id).is_empty() or quantity <= 0:
		return quantity

	add_resource(String(item_id), quantity)
	return 0


func withdraw(item_id: StringName, quantity: int) -> int:
	if remove_resource(String(item_id), quantity):
		return quantity

	return 0


func get_available(item_id: StringName) -> int:
	return get_resource(String(item_id))


func can_pay(costs: Dictionary) -> bool:
	return has_resources(costs)


func pay(costs: Dictionary) -> bool:
	return consume_resources(costs)


func get_all_items() -> Dictionary:
	return get_stock_snapshot()


func add_resource(resource_id: String, amount: int) -> void:
	var key := resource_id.strip_edges()
	if key.is_empty() or amount <= 0:
		return

	stock[key] = get_resource(key) + amount
	_sync_inventory_from_stock()
	warehouse_changed.emit(warehouse_id)


## Adiciona varios recursos em uma unica operacao atomica.
## Prefira este metodo quando houver multiplos recursos a depositar (ex: deposito do jogador).
## Garante apenas uma chamada a _sync_inventory_from_stock() e uma emissao de warehouse_changed.
func batch_add_resources(resources: Dictionary) -> void:
	var any_added := false
	for resource_id in resources.keys():
		var key := String(resource_id).strip_edges()
		var amount := int(resources[resource_id])
		if key.is_empty() or amount <= 0:
			continue
		stock[key] = get_resource(key) + amount
		any_added = true

	if any_added:
		_sync_inventory_from_stock()
		warehouse_changed.emit(warehouse_id)


func remove_resource(resource_id: String, amount: int) -> bool:
	var key := resource_id.strip_edges()
	if key.is_empty() or amount <= 0:
		return false
	if not has_resource(key, amount):
		return false

	var remaining := get_resource(key) - amount
	if remaining <= 0:
		stock.erase(key)
	else:
		stock[key] = remaining

	_sync_inventory_from_stock()
	warehouse_changed.emit(warehouse_id)
	return true


func get_resource(resource_id: String) -> int:
	var key := resource_id.strip_edges()
	if key.is_empty():
		return 0

	return int(stock.get(key, 0))


func has_resource(resource_id: String, amount: int) -> bool:
	var key := resource_id.strip_edges()
	if key.is_empty():
		return false
	if amount <= 0:
		return true

	return get_resource(key) >= amount


func has_resources(cost: Dictionary) -> bool:
	for resource_id in cost.keys():
		var key := String(resource_id).strip_edges()
		var amount := int(cost[resource_id])
		if key.is_empty() or amount < 0:
			return false
		if get_resource(key) < amount:
			return false

	return true


func consume_resources(cost: Dictionary) -> bool:
	if not has_resources(cost):
		return false

	for resource_id in cost.keys():
		var key := String(resource_id).strip_edges()
		var amount := int(cost[resource_id])
		if amount <= 0:
			continue

		var remaining := get_resource(key) - amount
		if remaining <= 0:
			stock.erase(key)
		else:
			stock[key] = remaining

	_sync_inventory_from_stock()
	warehouse_changed.emit(warehouse_id)
	return true


func get_stock_snapshot() -> Dictionary:
	var snapshot: Dictionary = {}
	for resource_id in stock.keys():
		snapshot[String(resource_id)] = int(stock[resource_id])

	return snapshot


func ensure_inventory() -> InventoryContainer:
	_ensure_inventory()
	return inventory


func _ensure_inventory() -> void:
	if inventory != null:
		return

	inventory = InventoryContainer.new()
	inventory.name = "WarehouseInventory"
	inventory.capacity_limit = capacity_limit
	add_child(inventory)
	inventory.inventory_changed.connect(_on_inventory_changed)


func _sync_inventory_from_stock() -> void:
	_ensure_inventory()
	_syncing_inventory = true
	inventory.clear()
	for resource_id in stock.keys():
		inventory.add_item(StringName(resource_id), int(stock[resource_id]))
	_syncing_inventory = false


func _on_inventory_changed() -> void:
	# Durante _sync_inventory_from_stock, ignorar: o stock já é a fonte de verdade
	# e warehouse_changed será emitido explicitamente ao final da operação.
	if _syncing_inventory:
		return
	if inventory != null:
		stock = inventory.get_all_resources()
	warehouse_changed.emit(warehouse_id)
