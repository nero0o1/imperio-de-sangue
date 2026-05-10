class_name SemanticIntegrityProbe
extends Node

const DomainEventLoggerScript = preload("res://scripts/debug/domain_event_logger.gd")

var violations: Array[String] = []


func reset() -> void:
	violations.clear()
	DomainEventLoggerScript.clear_idempotency_keys()


func snapshot_state(
	player_inventory: InventoryContainer = null,
	warehouse: Warehouse = null,
	building_site: BuildingSite = null
) -> Dictionary:
	var warehouse_items := {}
	if warehouse != null:
		warehouse_items = warehouse.get_all_items()

	return {
		"player": _inventory_items(player_inventory),
		"warehouse": warehouse_items,
		"building": {
			"progress": building_site.build_progress if building_site != null else 0.0,
			"is_completed": building_site.is_completed if building_site != null else false,
		},
	}


func record_operation(
	operation: String,
	actor: Node,
	resource_id: StringName,
	amount: int,
	source: String,
	target: String,
	success: bool,
	reason_if_failed: String,
	before: Dictionary,
	after: Dictionary,
	policy: String = "",
	entity_type: String = "semantic_probe",
	entity_id: String = "test_lab"
) -> Dictionary:
	var delta := DomainEventLoggerScript.calculate_delta(before, after)
	var invariant_result := _validate_invariants(operation, resource_id, amount, success, before, after, delta, policy)

	if invariant_result != "pass":
		violations.append("%s:%s" % [operation, invariant_result])

	var operation_id := DomainEventLoggerScript.make_operation_id(operation, entity_id)
	var idempotency_key := DomainEventLoggerScript.make_idempotency_key(operation_id, operation)

	return DomainEventLoggerScript.emit_event(
		"semantic_integrity.%s" % operation,
		operation_id,
		idempotency_key,
		entity_type,
		entity_id,
		policy,
		"success" if success else "blocked",
		before,
		after,
		delta,
		invariant_result,
		reason_if_failed,
		"INFO" if invariant_result == "pass" else "ERROR",
		{
			"actor": str(actor.name) if actor != null else "",
			"operation": operation,
			"resource_id": String(resource_id),
			"amount": amount,
			"source": source,
			"target": target,
			"success": success,
			"reason_if_failed": reason_if_failed,
			"invariant_result": invariant_result,
		}
	)


func get_report() -> Dictionary:
	return {
		"status": "pass" if violations.is_empty() else "fail",
		"violations": violations.duplicate(),
	}


func _validate_invariants(
	operation: String,
	resource_id: StringName,
	amount: int,
	success: bool,
	before: Dictionary,
	after: Dictionary,
	delta: Dictionary,
	policy: String
) -> String:
	if not DomainEventLoggerScript.validate_reconciliation(before, after, delta):
		return "fail_reconciliation"

	if DomainEventLoggerScript.has_negative_numbers(after):
		return "fail_negative_state"

	var before_player := _quantity(before, "player", resource_id)
	var after_player := _quantity(after, "player", resource_id)
	var before_warehouse := _quantity(before, "warehouse", resource_id)
	var after_warehouse := _quantity(after, "warehouse", resource_id)

	if operation == "warehouse_deposit" and success:
		if before_player + before_warehouse != after_player + after_warehouse:
			return "fail_transfer_not_conserved"

	if operation == "building_step" and success:
		if policy == "WAREHOUSE_ONLY" and after_player != before_player:
			return "fail_warehouse_only_touched_player"
		if before_warehouse - after_warehouse != amount:
			return "fail_build_cost_mismatch"

	if not success:
		if before_player != after_player:
			return "fail_blocked_changed_player"
		if before_warehouse != after_warehouse:
			return "fail_blocked_changed_warehouse"
		if before["building"]["progress"] != after["building"]["progress"]:
			return "fail_blocked_changed_progress"

	return "pass"


func _inventory_items(inventory: InventoryContainer) -> Dictionary:
	if inventory == null:
		return {}

	return inventory.get_all_items()


func _quantity(state: Dictionary, owner: String, item_id: StringName) -> int:
	var owner_state: Dictionary = state.get(owner, {})
	return int(owner_state.get(item_id, owner_state.get(String(item_id), 0)))
