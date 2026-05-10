extends StaticBody3D

const DomainEventLoggerScript = preload("res://scripts/debug/domain_event_logger.gd")

@export var warehouse_path: NodePath


func interact(actor: Node) -> void:
	var operation_id := DomainEventLoggerScript.make_operation_id("warehouse.deposit", String(name))
	var warehouse := _get_warehouse()

	if warehouse == null:
		push_warning("[WarehouseInteractable] Warehouse invalido ou nao configurado.")
		_emit_deposit_event(
			"warehouse.deposit.blocked_invalid_reference",
			operation_id,
			actor,
			null,
			warehouse,
			0,
			"blocked_invalid_reference",
			"warehouse_missing",
			_snapshot(null, warehouse),
			_snapshot(null, warehouse)
		)
		return

	var inventory := _find_actor_inventory(actor)
	var before := _snapshot(inventory, warehouse)

	if inventory == null:
		print("[WarehouseInteractable] Actor sem inventario.")
		_emit_deposit_event(
			"warehouse.deposit.blocked_invalid_reference",
			operation_id,
			actor,
			inventory,
			warehouse,
			0,
			"blocked_invalid_reference",
			"actor_inventory_missing",
			before,
			_snapshot(inventory, warehouse)
		)
		return

	var resources := inventory.get_all_resources() if inventory.has_method("get_all_resources") else _items_to_resources(inventory.get_all_items())
	var deposited_any := false
	var deposited_total := 0

	# Coleta todos os recursos removidos do inventario antes de depositar no armazem.
	# Garante que warehouse.batch_add_resources() seja chamado uma unica vez,
	# evitando N chamadas a _sync_inventory_from_stock() e N emissoes de warehouse_changed.
	var to_deposit: Dictionary = {}

	for resource_id in resources.keys():
		var amount := inventory.get_resource(String(resource_id)) if inventory.has_method("get_resource") else inventory.get_quantity(StringName(resource_id))
		if amount <= 0:
			continue

		var removed := inventory.remove_resource(String(resource_id), amount) if inventory.has_method("remove_resource") else inventory.remove_item(StringName(resource_id), amount) == amount
		if removed:
			to_deposit[String(resource_id)] = amount
			deposited_any = true
			deposited_total += amount
			print("[WarehouseInteractable] Depositado %s x%d." % [String(resource_id), amount])

	if deposited_any:
		warehouse.batch_add_resources(to_deposit)

	if not deposited_any:
		print("[WarehouseInteractable] Ator nao possui recursos para depositar.")
		_emit_deposit_event(
			"warehouse.deposit.blocked_no_resources",
			operation_id,
			actor,
			inventory,
			warehouse,
			0,
			"blocked_no_resources",
			"actor_has_no_resources",
			before,
			_snapshot(inventory, warehouse)
		)
		return

	_emit_deposit_event(
		"warehouse.deposit.success",
		operation_id,
		actor,
		inventory,
		warehouse,
		deposited_total,
		"success",
		"",
		before,
		_snapshot(inventory, warehouse)
	)


func _get_warehouse() -> Warehouse:
	if String(warehouse_path) == "":
		return null

	var node := get_node_or_null(warehouse_path)
	if node is Warehouse:
		return node

	return null


func get_warehouse() -> Warehouse:
	return _get_warehouse()


func get_available(item_id: StringName = &"") -> int:
	var warehouse := _get_warehouse()
	if warehouse == null or String(item_id).is_empty():
		return 0

	return warehouse.get_available(item_id)


func get_stock_snapshot() -> Dictionary:
	var warehouse := _get_warehouse()
	if warehouse == null:
		return {}

	return warehouse.get_stock_snapshot()


func _find_actor_inventory(actor: Node) -> InventoryContainer:
	if actor == null:
		return null

	if actor.has_method("get_inventory"):
		var from_method = actor.call("get_inventory")
		if from_method is InventoryContainer:
			return from_method

	var direct := actor.get_node_or_null("PlayerInventory")
	if direct is InventoryContainer:
		return direct

	return _find_inventory_recursive(actor)


func _find_inventory_recursive(node: Node) -> InventoryContainer:
	for child in node.get_children():
		if child is InventoryContainer:
			return child

		var nested := _find_inventory_recursive(child)
		if nested != null:
			return nested

	return null


func _snapshot(inventory: InventoryContainer, warehouse: Warehouse) -> Dictionary:
	var player_resources: Dictionary = {}
	if inventory != null:
		player_resources = inventory.get_all_resources() if inventory.has_method("get_all_resources") else _items_to_resources(inventory.get_all_items())

	return {
		"player": player_resources,
		"warehouse": warehouse.get_stock_snapshot() if warehouse != null else {},
	}


func _items_to_resources(items: Dictionary) -> Dictionary:
	var resources: Dictionary = {}
	for item_id in items.keys():
		resources[String(item_id)] = int(items[item_id])

	return resources


func _emit_deposit_event(
	event_name: String,
	operation_id: String,
	actor: Node,
	_inventory: InventoryContainer,
	warehouse: Warehouse,
	amount: int,
	result: String,
	failure_reason: String,
	before: Dictionary,
	after: Dictionary
) -> void:
	var semantic_integrity := "pass"
	var delta := DomainEventLoggerScript.calculate_economic_delta(before, after)

	if result == "success":
		for resource_id in _resource_keys(before, after):
			var player_delta := int(delta.get("player", {}).get(resource_id, 0))
			var warehouse_delta := int(delta.get("warehouse", {}).get(resource_id, 0))
			if player_delta + warehouse_delta != 0:
				semantic_integrity = "fail"
				failure_reason = "economic_conservation_failed"
				break
	else:
		for resource_id in _resource_keys(before, after):
			var player_delta := int(delta.get("player", {}).get(resource_id, 0))
			var warehouse_delta := int(delta.get("warehouse", {}).get(resource_id, 0))
			if player_delta != 0 or warehouse_delta != 0:
				semantic_integrity = "fail"
				failure_reason = "economic_conservation_failed"
				break

	for resource_id in _resource_keys(before, after):
		var before_total := int(before["player"].get(resource_id, 0)) + int(before["warehouse"].get(resource_id, 0))
		var after_total := int(after["player"].get(resource_id, 0)) + int(after["warehouse"].get(resource_id, 0))
		if before_total != after_total:
			semantic_integrity = "fail"
			failure_reason = "economic_conservation_failed"
			break

	DomainEventLoggerScript.emit_event(
		event_name,
		operation_id,
		DomainEventLoggerScript.make_idempotency_key(operation_id, event_name),
		"warehouse_interactable",
		String(name),
		"",
		result,
		before,
		after,
		delta,
		semantic_integrity,
		failure_reason,
		"WARN" if result.begins_with("blocked") or semantic_integrity == "fail" else "INFO",
		{
			"actor": str(actor.name) if actor != null else "",
			"operation": "deposit_all",
			"resource_id": "*",
			"amount": amount,
			"source": "PlayerInventory",
			"target": String(warehouse.warehouse_id) if warehouse != null else "",
			"success": result == "success",
			"reason_if_failed": failure_reason,
			"invariant_result": semantic_integrity,
		}
	)


func _resource_keys(before: Dictionary, after: Dictionary) -> Array[String]:
	# O(N) via Dictionary como conjunto. Evita Array.has() O(N) no loop interno.
	var seen: Dictionary = {}
	var keys: Array[String] = []
	for bucket in ["player", "warehouse"]:
		for source in [before, after]:
			for resource_id in source.get(bucket, {}).keys():
				var key := String(resource_id)
				if not seen.has(key):
					seen[key] = true
					keys.append(key)

	return keys
