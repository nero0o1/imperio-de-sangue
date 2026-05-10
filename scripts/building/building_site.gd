class_name BuildingSite
extends StaticBody3D

const DomainEventLoggerScript = preload("res://scripts/debug/domain_event_logger.gd")

signal construction_completed(building_site: BuildingSite)

@export var building_id: StringName = &"test_building"
@export var required_resources: Dictionary = {&"wood": 20, &"stone": 10}
@export var warehouse_path: NodePath
@export var step_count: int = 2
@export var build_progress: float = 0.0
@export var is_completed: bool = false
@export var max_health: float = 100.0
@export var current_health: float = 100.0

@export var consume_policy: int = BuildingResourceConsumer.ConsumePolicy.WAREHOUSE_ONLY

# Cache do custo por etapa computado em _ready(). required_resources e step_count sao
# @export e nao mudam em runtime — o cache e seguro durante toda a vida do no.
var _cached_step_cost: Dictionary = {}
var _completion_signal_emitted := false

var required_costs: Dictionary:
	get:
		return required_resources
	set(value):
		required_resources = value.duplicate(true)
var build_progress_per_payment: float:
	get:
		return _get_progress_per_step()
	set(_value):
		pass


func _ready() -> void:
	build_progress = clampf(build_progress, 0.0, 100.0)
	is_completed = is_completed or build_progress >= 100.0
	max_health = maxf(max_health, 1.0)
	current_health = clampf(current_health, 0.0, max_health)
	# Computa o custo antes de _validate_configuration() para que get_step_cost()
	# retorne o valor correto quando a validacao o chama.
	_cached_step_cost = _compute_step_cost()
	_validate_configuration()
	if is_completed:
		call_deferred("_emit_construction_completed_once")


func interact(actor: Node) -> void:
	build_step(actor)


func can_build_step(actor: Node = null) -> bool:
	if is_completed:
		return false

	var step_cost := get_step_cost()
	return not step_cost.is_empty() and not _resolve_payment_source(step_cost, actor).is_empty()


func build_step(actor: Node) -> bool:
	var warehouse := resolve_warehouse(actor)
	var inventory := _resolve_actor_inventory(actor)
	var before := _snapshot(warehouse, inventory)

	if is_completed:
		print("[BuildingSite] %s ja esta concluida. Nenhum recurso consumido." % String(building_id))
		_emit_build_event(
			"building_site.consume.blocked_completed",
			actor,
			{},
			"blocked_completed",
			"building_completed",
			before,
			_snapshot(warehouse, inventory),
			"",
			_payment_policy_label()
		)
		return false

	var step_cost := get_step_cost()
	if step_cost.is_empty():
		push_warning("[BuildingSite] Receita invalida para %s. Construcao bloqueada." % String(building_id))
		_emit_build_event(
			"building_site.consume.blocked_invalid_cost",
			actor,
			step_cost,
			"blocked_invalid_cost",
			"invalid_step_cost",
			before,
			_snapshot(warehouse, inventory),
			"",
			_payment_policy_label()
		)
		return false

	var payment_source := _resolve_payment_source(step_cost, actor)
	if payment_source.is_empty():
		print("[BuildingSite] Recursos insuficientes para %s. Custo: %s." % [String(building_id), _format_cost(step_cost)])
		_emit_build_event(
			"building_site.consume.blocked_no_stock",
			actor,
			step_cost,
			"blocked_no_stock",
			"insufficient_resources",
			before,
			_snapshot(warehouse, inventory),
			"",
			_payment_policy_label()
		)
		return false

	var source_name := String(payment_source.get("source", ""))
	if not _consume_from_payment_source(payment_source, step_cost):
		print("[BuildingSite] Falha ao consumir recursos de %s. Custo: %s." % [source_name, _format_cost(step_cost)])
		_emit_build_event(
			"building_site.consume.blocked_consume_failed",
			actor,
			step_cost,
			"blocked_consume_failed",
			"consume_resources_returned_false",
			before,
			_snapshot(warehouse, inventory),
			source_name,
			_payment_policy_label()
		)
		return false

	var was_completed := is_completed
	build_progress = minf(100.0, build_progress + _get_progress_per_step())
	is_completed = is_completed or build_progress >= 100.0

	print("[BuildingSite] %s recebeu pagamento: %s. Progresso: %.1f%%. Concluida: %s." % [
		String(building_id),
		_format_cost(step_cost),
		build_progress,
		str(is_completed),
	])
	_emit_build_event(
		"building_site.consume.success",
		actor,
		step_cost,
		"success",
		"",
		before,
		_snapshot(warehouse, inventory),
		source_name,
		_payment_policy_label()
	)

	if is_completed and not was_completed:
		_emit_construction_completed_once()

	return true


## Retorna o custo por etapa de construcao.
## O resultado e calculado uma unica vez em _ready() e retornado como copia defensiva.
## Chamadores podem mutar o retorno sem contaminar o cache interno.
## required_resources e step_count sao @export e nao mudam em runtime.
func get_step_cost() -> Dictionary:
	return _cached_step_cost.duplicate()


## Calcula o custo por etapa a partir de required_resources e step_count.
## Chamado apenas em _ready(). Nao deve ser chamado em runtime apos inicializacao.
func _compute_step_cost() -> Dictionary:
	if step_count <= 0:
		push_warning("[BuildingSite] step_count invalido para %s: %d." % [String(building_id), step_count])
		return {}

	var step_cost: Dictionary = {}
	for resource_id in required_resources.keys():
		var key := String(resource_id).strip_edges()
		var total_amount := int(required_resources[resource_id])
		if key.is_empty() or total_amount <= 0:
			push_warning("[BuildingSite] Recurso invalido na receita de %s: %s=%d." % [String(building_id), key, total_amount])
			return {}
		if total_amount % step_count != 0:
			push_warning("[BuildingSite] Recurso %s nao divisivel por step_count em %s: total=%d, step_count=%d." % [
				key,
				String(building_id),
				total_amount,
				step_count,
			])

		step_cost[key] = int(total_amount / float(step_count))

	return step_cost


func resolve_warehouse(_actor: Node = null) -> Warehouse:
	if String(warehouse_path) == "":
		return null

	var node := get_node_or_null(warehouse_path)
	if node is Warehouse:
		return node

	return null


func _validate_configuration() -> void:
	if step_count <= 0:
		push_warning("[BuildingSite] step_count deve ser maior que zero.")
	if required_resources.is_empty():
		push_warning("[BuildingSite] required_resources vazio para %s." % String(building_id))
	get_step_cost()


func _get_progress_per_step() -> float:
	if step_count <= 0:
		return 0.0

	return 100.0 / float(step_count)


func _emit_construction_completed_once() -> void:
	if _completion_signal_emitted or not is_completed:
		return

	_completion_signal_emitted = true
	current_health = max_health
	construction_completed.emit(self)


func is_damaged() -> bool:
	return current_health < max_health


func repair(amount: float) -> float:
	if amount <= 0.0 or not is_damaged():
		return 0.0

	var before := current_health
	current_health = minf(max_health, current_health + amount)
	print("[BuildingSite] %s reparada: %.1f/%.1f." % [String(building_id), current_health, max_health])
	return current_health - before


func damage_for_test(amount: float) -> float:
	if amount <= 0.0:
		return 0.0

	var before := current_health
	current_health = maxf(0.0, current_health - amount)
	print("[BuildingSite] %s recebeu dano de teste: %.1f/%.1f." % [String(building_id), current_health, max_health])
	return before - current_health


func _snapshot(warehouse: Warehouse, inventory: InventoryContainer = null) -> Dictionary:
	return {
		"warehouse": warehouse.get_stock_snapshot() if warehouse != null else {},
		"actor_inventory": inventory.get_all_resources() if inventory != null else {},
		"building": {
			"progress": build_progress,
			"is_completed": is_completed,
			"health": current_health,
			"max_health": max_health,
		},
	}


func _emit_build_event(
	event_name: String,
	actor: Node,
	cost: Dictionary,
	result: String,
	failure_reason: String,
	before: Dictionary,
	after: Dictionary,
	source: String = "",
	policy: String = ""
) -> void:
	var semantic_integrity := "pass"

	if result == "success":
		for resource_id in cost.keys():
			var key := String(resource_id)
			var source_key := "actor_inventory" if source == "ActorInventory" else "warehouse"
			var before_amount := int(before[source_key].get(key, 0))
			var after_amount := int(after[source_key].get(key, 0))
			if before_amount - after_amount != int(cost[resource_id]):
				semantic_integrity = "fail"
				failure_reason = "%s_cost_delta_mismatch" % source_key
				break
	else:
		for resource_id in _resource_keys(before, after):
			if int(before["warehouse"].get(resource_id, 0)) != int(after["warehouse"].get(resource_id, 0)):
				semantic_integrity = "fail"
				failure_reason = "blocked_build_mutated_warehouse"
				break
			if int(before["actor_inventory"].get(resource_id, 0)) != int(after["actor_inventory"].get(resource_id, 0)):
				semantic_integrity = "fail"
				failure_reason = "blocked_build_mutated_actor_inventory"
				break
		if before["building"]["progress"] != after["building"]["progress"]:
			semantic_integrity = "fail"
			failure_reason = "blocked_build_mutated_progress"

	var operation_id := DomainEventLoggerScript.make_operation_id("building_site.consume", String(building_id))
	DomainEventLoggerScript.emit_event(
		event_name,
		operation_id,
		DomainEventLoggerScript.make_idempotency_key(operation_id, event_name),
		"building_site",
		String(building_id),
		policy if not policy.is_empty() else _payment_policy_label(),
		result,
		before,
		after,
		DomainEventLoggerScript.calculate_delta(before, after),
		semantic_integrity,
		failure_reason,
		"WARN" if result.begins_with("blocked") else "INFO",
		{
			"actor": str(actor.name) if actor != null else "",
			"operation": "build_step",
			"resource_id": "*",
			"amount": _total_cost(cost),
			"source": source,
			"target": String(building_id),
			"success": result == "success",
			"reason_if_failed": failure_reason,
			"invariant_result": semantic_integrity,
			"cost": cost,
		}
	)


func _resource_keys(before: Dictionary, after: Dictionary) -> Array[String]:
	# O(N) via Dictionary como conjunto. Evita Array.has() O(N) no loop interno.
	var seen: Dictionary = {}
	var keys: Array[String] = []
	for source in [before, after]:
		for resource_id in source.get("warehouse", {}).keys():
			var key := String(resource_id)
			if not seen.has(key):
				seen[key] = true
				keys.append(key)
		for resource_id in source.get("actor_inventory", {}).keys():
			var key := String(resource_id)
			if not seen.has(key):
				seen[key] = true
				keys.append(key)

	return keys


func _resolve_payment_source(step_cost: Dictionary, actor: Node) -> Dictionary:
	var warehouse := resolve_warehouse(actor)
	var inventory := _resolve_actor_inventory(actor)

	match consume_policy:
		BuildingResourceConsumer.ConsumePolicy.PLAYER_ONLY, BuildingResourceConsumer.ConsumePolicy.INVENTORY_ONLY:
			return _payment_source_for_inventory(inventory, step_cost)
		BuildingResourceConsumer.ConsumePolicy.WAREHOUSE_ONLY:
			return _payment_source_for_warehouse(warehouse, step_cost)
		BuildingResourceConsumer.ConsumePolicy.WAREHOUSE_THEN_PLAYER, BuildingResourceConsumer.ConsumePolicy.WAREHOUSE_THEN_INVENTORY:
			var warehouse_source := _payment_source_for_warehouse(warehouse, step_cost)
			if not warehouse_source.is_empty():
				return warehouse_source
			return _payment_source_for_inventory(inventory, step_cost)
		BuildingResourceConsumer.ConsumePolicy.PLAYER_THEN_WAREHOUSE, BuildingResourceConsumer.ConsumePolicy.INVENTORY_THEN_WAREHOUSE:
			var inventory_source := _payment_source_for_inventory(inventory, step_cost)
			if not inventory_source.is_empty():
				return inventory_source
			return _payment_source_for_warehouse(warehouse, step_cost)

	return {}


func _payment_source_for_warehouse(warehouse: Warehouse, step_cost: Dictionary) -> Dictionary:
	if warehouse != null and warehouse.has_resources(step_cost):
		return {
			"source": "Warehouse",
			"warehouse": warehouse,
		}
	return {}


func _payment_source_for_inventory(inventory: InventoryContainer, step_cost: Dictionary) -> Dictionary:
	if inventory != null and inventory.has_items(step_cost):
		return {
			"source": "ActorInventory",
			"inventory": inventory,
		}
	return {}


func _consume_from_payment_source(payment_source: Dictionary, step_cost: Dictionary) -> bool:
	var source_name := String(payment_source.get("source", ""))
	if source_name == "Warehouse":
		var warehouse := payment_source.get("warehouse") as Warehouse
		return warehouse != null and warehouse.consume_resources(step_cost)
	if source_name == "ActorInventory":
		var inventory := payment_source.get("inventory") as InventoryContainer
		return inventory != null and inventory.remove_items(step_cost)
	return false


func _resolve_actor_inventory(actor: Node) -> InventoryContainer:
	if actor == null:
		return null
	if actor.has_method("get_inventory"):
		var found: Variant = actor.call("get_inventory")
		if found is InventoryContainer:
			return found
	if actor is InventoryContainer:
		return actor as InventoryContainer
	for child in actor.get_children():
		if child is InventoryContainer:
			return child as InventoryContainer
		var nested := _resolve_actor_inventory(child)
		if nested != null:
			return nested
	return null


func _payment_policy_label() -> String:
	match consume_policy:
		BuildingResourceConsumer.ConsumePolicy.PLAYER_ONLY, BuildingResourceConsumer.ConsumePolicy.INVENTORY_ONLY:
			return "INVENTORY_ONLY"
		BuildingResourceConsumer.ConsumePolicy.WAREHOUSE_ONLY:
			return "WAREHOUSE_ONLY"
		BuildingResourceConsumer.ConsumePolicy.WAREHOUSE_THEN_PLAYER, BuildingResourceConsumer.ConsumePolicy.WAREHOUSE_THEN_INVENTORY:
			return "WAREHOUSE_THEN_INVENTORY"
		BuildingResourceConsumer.ConsumePolicy.PLAYER_THEN_WAREHOUSE, BuildingResourceConsumer.ConsumePolicy.INVENTORY_THEN_WAREHOUSE:
			return "INVENTORY_THEN_WAREHOUSE"
	return "UNKNOWN"


func _format_cost(cost: Dictionary) -> String:
	var parts: Array[String] = []
	for resource_id in cost.keys():
		parts.append("\"%s\":%d" % [String(resource_id), int(cost[resource_id])])

	return "{" + ",".join(parts) + "}"


func _total_cost(cost: Dictionary) -> int:
	var total := 0
	for resource_id in cost.keys():
		total += int(cost[resource_id])

	return total
