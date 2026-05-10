extends StaticBody3D

const DomainEventLoggerScript = preload("res://scripts/debug/domain_event_logger.gd")

@export var item_id: StringName = &"wood"
@export var quantity: int = 1
@export var resource_id: String = "wood"
@export var amount: int = 1
@export var amount_per_interaction: int = 1
@export var remove_when_depleted: bool = true


func interact(actor: Node) -> void:
	_sync_legacy_fields()
	var operation_id := DomainEventLoggerScript.make_operation_id("resource_pickup.collect", resource_id)

	if resource_id.strip_edges().is_empty():
		push_warning("[ResourcePickup] resource_id vazio. Coleta cancelada.")
		_emit_pickup_event(
			"resource_pickup.collect.blocked_invalid_item",
			operation_id,
			actor,
			0,
			"blocked_invalid_item",
			"resource_id_empty",
			_snapshot(null),
			_snapshot(null)
		)
		return

	if amount <= 0:
		print("[ResourcePickup] %s esgotado. Removendo pickup." % resource_id)
		_emit_pickup_event(
			"resource_pickup.collect.blocked_depleted",
			operation_id,
			actor,
			0,
			"blocked_depleted",
			"resource_depleted",
			_snapshot(null),
			_snapshot(null)
		)
		_deplete_pickup()
		return

	if amount_per_interaction <= 0:
		push_warning("[ResourcePickup] amount_per_interaction invalido para %s: %d." % [resource_id, amount_per_interaction])
		_emit_pickup_event(
			"resource_pickup.collect.blocked_invalid_quantity",
			operation_id,
			actor,
			0,
			"blocked_invalid_quantity",
			"amount_per_interaction_lte_zero",
			_snapshot(null),
			_snapshot(null)
		)
		return

	var inventory := _find_actor_inventory(actor)
	var before := _snapshot(inventory)
	if inventory == null:
		push_warning("[ResourcePickup] Actor nao possui inventario. Coleta de %s cancelada." % resource_id)
		_emit_pickup_event(
			"resource_pickup.collect.blocked_invalid_reference",
			operation_id,
			actor,
			0,
			"blocked_invalid_reference",
			"actor_inventory_missing",
			before,
			_snapshot(inventory)
		)
		return

	var requested: int = min(amount_per_interaction, amount)
	var leftover: int = inventory.add_item(StringName(resource_id), requested)
	var accepted: int = requested - leftover

	if accepted <= 0:
		print("[ResourcePickup] Inventario nao aceitou %s. Restante no mapa: %d." % [resource_id, amount])
		_emit_pickup_event(
			"resource_pickup.collect.blocked_inventory_full",
			operation_id,
			actor,
			0,
			"blocked_inventory_full",
			"inventory_rejected_item",
			before,
			_snapshot(inventory)
		)
		return

	amount = max(0, amount - accepted)
	quantity = amount
	print("[ResourcePickup] Coletado %s x%d. Restante: %d." % [resource_id, accepted, amount])
	_emit_pickup_event(
		"resource_pickup.collect.success",
		operation_id,
		actor,
		accepted,
		"success",
		"",
		before,
		_snapshot(inventory)
	)

	if amount <= 0:
		print("[ResourcePickup] %s esgotado. Removendo pickup." % resource_id)
		_deplete_pickup()

func _deplete_pickup() -> void:
	if remove_when_depleted:
		queue_free()


func _find_actor_inventory(actor: Node) -> InventoryContainer:
	if actor == null:
		return null

	if actor.has_method("get_inventory"):
		var from_method = actor.call("get_inventory")
		if from_method is InventoryContainer:
			return from_method

	var direct := actor.get_node_or_null("PlayerInventory")
	if direct is PlayerInventory:
		return direct

	return _find_player_inventory_recursive(actor)


func _find_player_inventory_recursive(node: Node) -> PlayerInventory:
	for child in node.get_children():
		if child is PlayerInventory:
			return child

		var nested := _find_player_inventory_recursive(child)
		if nested != null:
			return nested

	return null


func _set_pickup_enabled(enabled: bool) -> void:
	visible = enabled
	process_mode = Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED

	for child in get_children():
		if child is CollisionShape3D:
			child.disabled = not enabled


func _actor_name(actor: Node) -> String:
	if actor == null:
		return "Actor desconhecido"

	return str(actor.name)


func _sync_legacy_fields() -> void:
	if resource_id.strip_edges().is_empty() and not String(item_id).is_empty():
		resource_id = String(item_id)
	if amount <= 0 and quantity > 0:
		amount = quantity
	item_id = StringName(resource_id)
	quantity = amount


func _snapshot(inventory: InventoryContainer) -> Dictionary:
	return {
		"player": {
			resource_id: inventory.get_quantity(StringName(resource_id)) if inventory != null else 0,
		},
		"pickup": {
			resource_id: amount,
		},
	}


func _emit_pickup_event(
	event_name: String,
	operation_id: String,
	actor: Node,
	collected_amount: int,
	result: String,
	failure_reason: String,
	before: Dictionary,
	after: Dictionary
) -> void:
	DomainEventLoggerScript.emit_event(
		event_name,
		operation_id,
		DomainEventLoggerScript.make_idempotency_key(operation_id, event_name),
		"resource_pickup",
		String(name),
		"",
		result,
		before,
		after,
		DomainEventLoggerScript.calculate_delta(before, after),
		"pass",
		failure_reason,
		"WARN" if result.begins_with("blocked") else "INFO",
		{
			"actor": _actor_name(actor),
			"operation": "collect",
			"resource_id": resource_id,
			"amount": collected_amount,
			"source": String(name),
			"target": "PlayerInventory",
			"success": result == "success",
			"reason_if_failed": failure_reason,
			"invariant_result": "pass",
		}
	)
