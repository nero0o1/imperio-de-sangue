class_name BuildingResourceConsumer
extends Node

enum ConsumePolicy {
	PLAYER_ONLY,
	WAREHOUSE_ONLY,
	PLAYER_THEN_WAREHOUSE,
	WAREHOUSE_THEN_PLAYER,
	INVENTORY_ONLY = PLAYER_ONLY,
	INVENTORY_THEN_WAREHOUSE = PLAYER_THEN_WAREHOUSE,
	WAREHOUSE_THEN_INVENTORY = WAREHOUSE_THEN_PLAYER
}

@export var consume_policy: ConsumePolicy = ConsumePolicy.WAREHOUSE_THEN_PLAYER


func can_consume(
	costs: Dictionary,
	player_inventory: InventoryContainer = null,
	warehouse: Warehouse = null
) -> bool:
	if not _are_costs_valid(costs):
		return false

	match consume_policy:
		ConsumePolicy.PLAYER_ONLY:
			return player_inventory != null and player_inventory.has_items(costs)

		ConsumePolicy.WAREHOUSE_ONLY:
			return warehouse != null and warehouse.can_pay(costs)

		ConsumePolicy.PLAYER_THEN_WAREHOUSE, ConsumePolicy.WAREHOUSE_THEN_PLAYER:
			return _combined_has_items(costs, player_inventory, warehouse)

	return false


func consume(
	costs: Dictionary,
	player_inventory: InventoryContainer = null,
	warehouse: Warehouse = null
) -> bool:
	if not can_consume(costs, player_inventory, warehouse):
		return false

	match consume_policy:
		ConsumePolicy.PLAYER_ONLY:
			return player_inventory != null and player_inventory.remove_items(costs)

		ConsumePolicy.WAREHOUSE_ONLY:
			return warehouse != null and warehouse.pay(costs)

		ConsumePolicy.PLAYER_THEN_WAREHOUSE:
			return _consume_split(
				costs,
				player_inventory,
				_get_warehouse_inventory(warehouse)
			)

		ConsumePolicy.WAREHOUSE_THEN_PLAYER:
			return _consume_split(
				costs,
				_get_warehouse_inventory(warehouse),
				player_inventory
			)

	return false


func _are_costs_valid(costs: Dictionary) -> bool:
	if costs.is_empty():
		push_warning("[BuildingResourceConsumer] Custo vazio. Consumo bloqueado.")
		return false

	for item_id in costs.keys():
		var quantity: int = int(costs[item_id])
		if String(item_id) == "":
			push_warning("[BuildingResourceConsumer] item_id vazio em custos. Consumo bloqueado.")
			return false
		if quantity <= 0:
			push_warning("[BuildingResourceConsumer] Quantidade invalida para %s: %d." % [String(item_id), quantity])
			return false

	return true


func _combined_has_items(
	costs: Dictionary,
	player_inventory: InventoryContainer,
	warehouse: Warehouse
) -> bool:
	if not _are_costs_valid(costs):
		return false

	for item_id in costs.keys():
		var required: int = int(costs[item_id])
		var total: int = 0

		if player_inventory != null:
			total += player_inventory.get_quantity(item_id)

		if warehouse != null:
			total += warehouse.get_available(item_id)

		if total < required:
			return false

	return true


func _consume_split(costs: Dictionary, primary: InventoryContainer, secondary: InventoryContainer) -> bool:
	if not _are_costs_valid(costs):
		return false

	if primary == null and secondary == null:
		return false

	for item_id in costs.keys():
		var remaining: int = int(costs[item_id])

		if primary != null and remaining > 0:
			remaining -= primary.remove_item(item_id, remaining)

		if secondary != null and remaining > 0:
			remaining -= secondary.remove_item(item_id, remaining)

		if remaining > 0:
			push_error("[BuildingResourceConsumer] Falha critica: validacao permitiu consumo sem recursos suficientes.")
			return false

	return true


func _get_warehouse_inventory(warehouse: Warehouse) -> InventoryContainer:
	if warehouse == null:
		return null

	var warehouse_inventory := warehouse.ensure_inventory()
	if warehouse_inventory is InventoryContainer:
		return warehouse_inventory

	return null
