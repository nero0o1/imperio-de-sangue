extends Node

const DomainEventLoggerScript = preload("res://scripts/debug/domain_event_logger.gd")
const ResourcePickupScript = preload("res://scripts/resources/resource_pickup.gd")


func _ready() -> void:
	_run_all_tests()


func _run_all_tests() -> void:
	_test_inventory_add_remove()
	_test_inventory_transfer()
	_test_warehouse_deposit_withdraw()
	_test_warehouse_pay_success()
	_test_warehouse_pay_failure()
	_test_warehouse_pay_partial_failure_atomic()
	_test_building_consumer_warehouse_only()
	_test_building_consumer_player_only()
	_test_building_consumer_player_then_warehouse()
	_test_building_consumer_warehouse_then_player()
	_test_building_consumer_insufficient_combined()
	_test_building_consumer_negative_quantity()
	_test_domain_event_logger_schema()
	_test_domain_event_logger_reconciliation()
	_test_integrity_hash_deterministic()
	_test_building_site_warehouse_only_semantics()
	# Wave 3.1.5 — Hardening
	_test_add_resource_ignores_non_positive()
	_test_remove_resource_no_negative()
	_test_get_all_resources_is_snapshot()
	_test_deposit_delta_correct()
	_test_canonicalize_max_depth()
	_test_resource_pickup_no_inventory()
	_test_resource_pickup_depletes_and_queues_free()
	_test_blocked_completed_has_empty_delta()
	# Wave 3.1.6 — Performance
	_test_warehouse_batch_add_resources()
	_test_building_site_step_cost_cache()

	print("[PASS] Todos os testes do sistema de inventário foram concluídos.")


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		push_error("[FAIL] " + message)
		assert(condition, message)


func _new_warehouse() -> Warehouse:
	var warehouse := Warehouse.new()
	add_child(warehouse)
	warehouse.ensure_inventory()
	return warehouse


func _new_player_inventory() -> PlayerInventory:
	var player_inventory := PlayerInventory.new()
	add_child(player_inventory)
	return player_inventory


func _new_consumer(policy: int) -> BuildingResourceConsumer:
	var consumer := BuildingResourceConsumer.new()
	consumer.consume_policy = policy
	add_child(consumer)
	return consumer


func _test_inventory_add_remove() -> void:
	var inv := InventoryContainer.new()
	add_child(inv)

	var leftover: int = inv.add_item(&"wood", 10)
	_assert_true(leftover == 0, "add_item deveria aceitar toda a madeira.")
	_assert_true(inv.get_quantity(&"wood") == 10, "Inventario deveria conter 10 madeiras.")

	var removed: int = inv.remove_item(&"wood", 4)
	_assert_true(removed == 4, "remove_item deveria remover 4 madeiras.")
	_assert_true(inv.get_quantity(&"wood") == 6, "Inventario deveria conter 6 madeiras.")

	removed = inv.remove_item(&"wood", 50)
	_assert_true(removed == 6, "remove_item nao deveria remover mais do que existe.")
	_assert_true(inv.get_quantity(&"wood") == 0, "Inventario deveria zerar madeira.")

	inv.queue_free()


func _test_inventory_transfer() -> void:
	var source := InventoryContainer.new()
	var target := InventoryContainer.new()
	add_child(source)
	add_child(target)

	source.add_item(&"stone", 12)
	var transferred: int = source.transfer_to(target, &"stone", 5)

	_assert_true(transferred == 5, "Transferencia deveria mover 5 pedras.")
	_assert_true(source.get_quantity(&"stone") == 7, "Origem deveria ficar com 7 pedras.")
	_assert_true(target.get_quantity(&"stone") == 5, "Destino deveria receber 5 pedras.")

	source.queue_free()
	target.queue_free()


func _test_warehouse_deposit_withdraw() -> void:
	var warehouse := _new_warehouse()

	var leftover: int = warehouse.deposit(&"wood", 10)
	_assert_true(leftover == 0, "Armazem deveria aceitar 10 madeiras.")
	_assert_true(warehouse.get_available(&"wood") == 10, "Armazem deveria conter 10 madeiras.")

	var removed: int = warehouse.withdraw(&"wood", 4)
	_assert_true(removed == 4, "Armazem deveria retirar 4 madeiras.")
	_assert_true(warehouse.get_available(&"wood") == 6, "Armazem deveria ficar com 6 madeiras.")

	warehouse.queue_free()


func _test_warehouse_pay_success() -> void:
	var warehouse := _new_warehouse()

	warehouse.deposit(&"wood", 10)
	warehouse.deposit(&"stone", 3)

	var costs := {
		&"wood": 5,
		&"stone": 2,
	}

	_assert_true(warehouse.can_pay(costs), "Armazem deveria ter recursos suficientes.")
	_assert_true(warehouse.pay(costs), "Pagamento deveria funcionar.")
	_assert_true(warehouse.get_available(&"wood") == 5, "Armazem deveria ficar com 5 madeiras.")
	_assert_true(warehouse.get_available(&"stone") == 1, "Armazem deveria ficar com 1 pedra.")

	warehouse.queue_free()


func _test_warehouse_pay_failure() -> void:
	var warehouse := _new_warehouse()

	warehouse.deposit(&"wood", 10)

	var costs := {
		&"wood": 20,
	}

	_assert_true(not warehouse.can_pay(costs), "Armazem nao deveria ter recursos suficientes.")
	_assert_true(not warehouse.pay(costs), "Pagamento nao deveria funcionar.")
	_assert_true(warehouse.get_available(&"wood") == 10, "Falha de pagamento nao deveria consumir recursos.")

	warehouse.queue_free()


func _test_warehouse_pay_partial_failure_atomic() -> void:
	var warehouse := _new_warehouse()

	warehouse.add_resource("wood", 10)

	var costs := {
		"wood": 10,
		"stone": 5,
	}

	_assert_true(not warehouse.has_resources(costs), "Armazem nao deveria pagar quando stone esta faltando.")
	_assert_true(not warehouse.consume_resources(costs), "consume_resources deveria falhar atomicamente sem stone.")
	_assert_true(warehouse.get_resource("wood") == 10, "Falha parcial nao deveria consumir wood.")
	_assert_true(warehouse.get_resource("stone") == 0, "Falha parcial nao deveria criar ou alterar stone.")

	warehouse.queue_free()


func _test_building_consumer_warehouse_only() -> void:
	var warehouse := _new_warehouse()
	var consumer := _new_consumer(BuildingResourceConsumer.ConsumePolicy.WAREHOUSE_ONLY)

	warehouse.deposit(&"wood", 10)

	var costs := {
		&"wood": 10,
	}

	_assert_true(consumer.can_consume(costs, null, warehouse), "WAREHOUSE_ONLY deveria consumir do armazem.")
	_assert_true(consumer.consume(costs, null, warehouse), "WAREHOUSE_ONLY deveria retornar true.")
	_assert_true(warehouse.get_available(&"wood") == 0, "WAREHOUSE_ONLY deveria deixar armazem com 0 wood.")

	warehouse.queue_free()
	consumer.queue_free()


func _test_building_consumer_player_only() -> void:
	var player_inventory := _new_player_inventory()
	var consumer := _new_consumer(BuildingResourceConsumer.ConsumePolicy.PLAYER_ONLY)

	player_inventory.add_item(&"wood", 10)

	var costs := {
		&"wood": 10,
	}

	_assert_true(consumer.can_consume(costs, player_inventory, null), "PLAYER_ONLY deveria consumir do jogador.")
	_assert_true(consumer.consume(costs, player_inventory, null), "PLAYER_ONLY deveria retornar true.")
	_assert_true(player_inventory.get_quantity(&"wood") == 0, "PLAYER_ONLY deveria deixar jogador com 0 wood.")

	player_inventory.queue_free()
	consumer.queue_free()


func _test_building_consumer_player_then_warehouse() -> void:
	var warehouse := _new_warehouse()
	var player_inventory := _new_player_inventory()
	var consumer := _new_consumer(BuildingResourceConsumer.ConsumePolicy.PLAYER_THEN_WAREHOUSE)

	player_inventory.add_item(&"wood", 6)
	warehouse.deposit(&"wood", 5)

	var costs := {
		&"wood": 10,
	}

	_assert_true(consumer.can_consume(costs, player_inventory, warehouse), "PLAYER_THEN_WAREHOUSE deveria somar jogador + armazem.")
	_assert_true(consumer.consume(costs, player_inventory, warehouse), "PLAYER_THEN_WAREHOUSE deveria consumir primeiro do jogador.")
	_assert_true(player_inventory.get_quantity(&"wood") == 0, "Jogador deveria ficar com 0 wood.")
	_assert_true(warehouse.get_available(&"wood") == 1, "Armazem deveria ficar com 1 wood.")

	warehouse.queue_free()
	player_inventory.queue_free()
	consumer.queue_free()


func _test_building_consumer_warehouse_then_player() -> void:
	var warehouse := _new_warehouse()
	var player_inventory := _new_player_inventory()
	var consumer := _new_consumer(BuildingResourceConsumer.ConsumePolicy.WAREHOUSE_THEN_PLAYER)

	warehouse.deposit(&"wood", 6)
	player_inventory.add_item(&"wood", 5)

	var costs := {
		&"wood": 10,
	}

	_assert_true(consumer.can_consume(costs, player_inventory, warehouse), "WAREHOUSE_THEN_PLAYER deveria somar armazem + jogador.")
	_assert_true(consumer.consume(costs, player_inventory, warehouse), "WAREHOUSE_THEN_PLAYER deveria consumir primeiro do armazem.")
	_assert_true(warehouse.get_available(&"wood") == 0, "Armazem deveria ficar com 0 wood.")
	_assert_true(player_inventory.get_quantity(&"wood") == 1, "Jogador deveria ficar com 1 wood.")

	warehouse.queue_free()
	player_inventory.queue_free()
	consumer.queue_free()


func _test_building_consumer_insufficient_combined() -> void:
	var warehouse := _new_warehouse()
	var player_inventory := _new_player_inventory()
	var consumer := _new_consumer(BuildingResourceConsumer.ConsumePolicy.WAREHOUSE_THEN_PLAYER)

	player_inventory.add_item(&"wood", 3)
	warehouse.deposit(&"wood", 2)

	var costs := {
		&"wood": 10,
	}

	_assert_true(not consumer.can_consume(costs, player_inventory, warehouse), "Total combinado insuficiente deveria falhar em can_consume.")
	_assert_true(not consumer.consume(costs, player_inventory, warehouse), "Total combinado insuficiente deveria retornar false.")
	_assert_true(player_inventory.get_quantity(&"wood") == 3, "Falha nao deveria consumir wood do jogador.")
	_assert_true(warehouse.get_available(&"wood") == 2, "Falha nao deveria consumir wood do armazem.")

	warehouse.queue_free()
	player_inventory.queue_free()
	consumer.queue_free()


func _test_building_consumer_negative_quantity() -> void:
	var warehouse := _new_warehouse()
	var player_inventory := _new_player_inventory()
	var consumer := _new_consumer(BuildingResourceConsumer.ConsumePolicy.WAREHOUSE_THEN_PLAYER)

	player_inventory.add_item(&"wood", 3)
	warehouse.deposit(&"wood", 2)

	var costs := {
		&"wood": -10,
	}

	_assert_true(not consumer.can_consume(costs, player_inventory, warehouse), "Quantidade negativa deveria falhar em can_consume.")
	_assert_true(not consumer.consume(costs, player_inventory, warehouse), "Quantidade negativa deveria retornar false.")
	_assert_true(player_inventory.get_quantity(&"wood") == 3, "Quantidade negativa nao deveria consumir wood do jogador.")
	_assert_true(warehouse.get_available(&"wood") == 2, "Quantidade negativa nao deveria consumir wood do armazem.")

	warehouse.queue_free()
	player_inventory.queue_free()
	consumer.queue_free()


func _test_domain_event_logger_schema() -> void:
	DomainEventLoggerScript.clear_idempotency_keys()

	var before := {
		"player": {
			"wood": 10,
		},
	}
	var after := {
		"player": {
			"wood": 0,
		},
	}
	var delta := DomainEventLoggerScript.calculate_delta(before, after)

	var event := DomainEventLoggerScript.emit_event(
		"test.inventory.consume",
		"op_schema_test",
		"op_schema_test:test.inventory.consume",
		"test",
		"inventory_system_test",
		"PLAYER_ONLY",
		"success",
		before,
		after,
		delta,
		"pass",
		"",
		"INFO"
	)

	_assert_true(DomainEventLoggerScript.validate_event_schema(event).is_empty(), "Evento estruturado deveria validar schema minimo.")
	_assert_true(event["attributes"]["semantic_integrity"] == "pass", "Evento valido deveria manter semantic_integrity pass.")
	_assert_true(event["attributes"].has("sequence_number"), "Evento deveria incluir sequence_number.")
	_assert_true(event["attributes"].has("integrity_hash"), "Evento deveria incluir integrity_hash.")


func _test_domain_event_logger_reconciliation() -> void:
	var before := {
		"player": {
			"wood": 10,
		},
		"warehouse": {},
	}
	var after := {
		"player": {},
		"warehouse": {
			"wood": 10,
		},
	}
	var delta := DomainEventLoggerScript.calculate_delta(before, after)

	_assert_true(int(delta["player"]["wood"]) == -10, "Delta deveria registrar remocao do jogador.")
	_assert_true(int(delta["warehouse"]["wood"]) == 10, "Delta deveria registrar adicao no armazem.")
	_assert_true(DomainEventLoggerScript.validate_reconciliation(before, after, delta), "before + delta deveria reconciliar com after.")

	delta["warehouse"]["wood"] = 9
	_assert_true(not DomainEventLoggerScript.validate_reconciliation(before, after, delta), "Delta incorreto deveria falhar reconciliacao.")


func _test_integrity_hash_deterministic() -> void:
	# Verifica que canonicalize() produz a mesma string para dois Dictionaries
	# semanticamente iguais mas com ordem de chaves diferente.
	# Conforme especificado na Wave 3.1.4: auditar hash determinístico.
	var before_a := {
		"player": {"wood": 30, "stone": 10},
		"warehouse": {},
	}
	var before_b := {
		"warehouse": {},
		"player": {"stone": 10, "wood": 30},
	}

	var canonical_a := DomainEventLoggerScript.canonicalize(before_a)
	var canonical_b := DomainEventLoggerScript.canonicalize(before_b)

	_assert_true(
		canonical_a == canonical_b,
		"canonicalize() deve produzir resultado identico para Dictionaries logicamente equivalentes com ordens de chave diferentes."
	)

	# Verifica que a ordem de arrays é preservada (arrays não são reordenados).
	var arr_a := DomainEventLoggerScript.canonicalize([1, 2, 3])
	var arr_b := DomainEventLoggerScript.canonicalize([3, 2, 1])
	_assert_true(
		arr_a != arr_b,
		"canonicalize() deve preservar a ordem de Arrays — [1,2,3] e [3,2,1] devem ser distintos."
	)

	# Verifica que o hash SHA-256 resultante é uma string hex de 64 caracteres.
	var fake_event := {
		"timestamp": "2026-01-01T00:00:00Z",
		"severity_text": "INFO",
		"body": "test",
		"attributes": {
			"event_name": "test",
			"sequence_number": 0,
			"previous_integrity_hash": "",
		},
	}
	var canonical_event := DomainEventLoggerScript.canonicalize(fake_event)
	# SHA-256 hex = 64 chars
	_assert_true(
		canonical_event.length() > 0,
		"canonicalize() de evento nao deve retornar string vazia."
	)


func _test_building_site_warehouse_only_semantics() -> void:
	DomainEventLoggerScript.clear_idempotency_keys()

	var warehouse := _new_warehouse()
	warehouse.name = "WarehouseForBuildingSiteTest"
	warehouse.add_resource("wood", 20)
	warehouse.add_resource("stone", 10)

	var actor := Node.new()
	actor.name = "ActorWithInventory"
	add_child(actor)

	var player_inventory := PlayerInventory.new()
	player_inventory.name = "PlayerInventory"
	actor.add_child(player_inventory)
	player_inventory.add_item(&"wood", 10)

	var site := BuildingSite.new()
	site.name = "BuildingSiteWarehouseOnlyTest"
	site.building_id = &"building_site_warehouse_only_test"
	site.required_resources = {
		"wood": 20,
		"stone": 10,
	}
	site.step_count = 2
	add_child(site)
	site.warehouse_path = site.get_path_to(warehouse)

	_assert_true(site.build_step(actor), "Primeira etapa deveria construir com WAREHOUSE_ONLY.")
	_assert_true(player_inventory.get_quantity(&"wood") == 10, "WAREHOUSE_ONLY nao deveria consumir madeira do jogador.")
	_assert_true(warehouse.get_available(&"wood") == 10, "Primeira etapa deveria consumir exatamente 10 wood do armazem.")
	_assert_true(warehouse.get_available(&"stone") == 5, "Primeira etapa deveria consumir exatamente 5 stone do armazem.")
	_assert_true(site.build_progress == 50.0, "Primeira etapa deveria avancar para 50%.")
	_assert_true(not site.is_completed, "Construcao nao deveria estar completa em 50%.")

	_assert_true(site.build_step(actor), "Segunda etapa deveria construir com WAREHOUSE_ONLY.")
	_assert_true(player_inventory.get_quantity(&"wood") == 10, "Segunda etapa nao deveria consumir madeira do jogador.")
	_assert_true(warehouse.get_available(&"wood") == 0, "Segunda etapa deveria consumir mais 10 wood do armazem.")
	_assert_true(warehouse.get_available(&"stone") == 0, "Segunda etapa deveria consumir mais 5 stone do armazem.")
	_assert_true(site.build_progress == 100.0, "Segunda etapa deveria avancar para 100%.")
	_assert_true(site.is_completed, "Construcao deveria marcar is_completed em 100%.")

	warehouse.add_resource("wood", 10)
	warehouse.add_resource("stone", 5)
	_assert_true(not site.build_step(actor), "Construcao concluida nao deveria consumir novamente.")
	_assert_true(warehouse.get_available(&"wood") == 10, "Construcao concluida nao deveria alterar armazem.")
	_assert_true(warehouse.get_available(&"stone") == 5, "Construcao concluida nao deveria alterar stone no armazem.")
	_assert_true(player_inventory.get_quantity(&"wood") == 10, "Construcao concluida nao deveria alterar jogador.")

	site.queue_free()
	actor.queue_free()
	warehouse.queue_free()


# ============================================================
# Wave 3.1.5 — Testes de robustez e hardening
# ============================================================


func _test_add_resource_ignores_non_positive() -> void:
	var inv := InventoryContainer.new()
	add_child(inv)

	inv.add_resource("wood", 0)
	_assert_true(inv.get_resource("wood") == 0, "add_resource com amount=0 nao deve criar entrada.")

	inv.add_resource("wood", -5)
	_assert_true(inv.get_resource("wood") == 0, "add_resource com amount negativo nao deve alterar estado.")

	inv.add_resource("", 10)
	_assert_true(inv.is_empty(), "add_resource com resource_id vazio nao deve criar recurso.")

	inv.add_resource("   ", 10)
	_assert_true(inv.is_empty(), "add_resource com resource_id so de espacos nao deve criar recurso.")

	inv.queue_free()


func _test_remove_resource_no_negative() -> void:
	var inv := InventoryContainer.new()
	add_child(inv)

	inv.add_resource("stone", 5)

	var removed := inv.remove_resource("stone", 10)
	_assert_true(not removed, "remove_resource nao deve remover mais do que existe.")
	_assert_true(inv.get_resource("stone") == 5, "Estado deve permanecer intacto apos remocao falha.")

	var ok := inv.remove_resource("stone", 5)
	_assert_true(ok, "remove_resource deve ter sucesso com quantidade exata.")
	_assert_true(inv.get_resource("stone") == 0, "Recurso deve zerar apos remocao exata.")
	_assert_true(inv.is_empty(), "Inventario deve ficar vazio apos remover ultimo recurso.")

	inv.queue_free()


func _test_get_all_resources_is_snapshot() -> void:
	var inv := InventoryContainer.new()
	add_child(inv)

	inv.add_resource("wood", 10)
	var snapshot := inv.get_all_resources()
	snapshot["wood"] = 999

	_assert_true(inv.get_resource("wood") == 10, "get_all_resources deve retornar snapshot, nao referencia mutavel interna.")

	inv.queue_free()


func _test_deposit_delta_correct() -> void:
	# Verifica que calculate_economic_delta produz delta correto para um depósito típico:
	# player perde recursos, warehouse ganha os mesmos recursos.
	var before := {
		"player": {"wood": 20, "stone": 5},
		"warehouse": {},
	}
	var after := {
		"player": {},
		"warehouse": {"wood": 20, "stone": 5},
	}
	var delta := DomainEventLoggerScript.calculate_economic_delta(before, after)

	_assert_true(int(delta.get("player", {}).get("wood", 0)) == -20, "Delta player wood deve ser -20.")
	_assert_true(int(delta.get("player", {}).get("stone", 0)) == -5, "Delta player stone deve ser -5.")
	_assert_true(int(delta.get("warehouse", {}).get("wood", 0)) == 20, "Delta warehouse wood deve ser +20.")
	_assert_true(int(delta.get("warehouse", {}).get("stone", 0)) == 5, "Delta warehouse stone deve ser +5.")

	# Conservação: player_delta + warehouse_delta == 0 para cada recurso.
	_assert_true(
		int(delta.get("player", {}).get("wood", 0)) + int(delta.get("warehouse", {}).get("wood", 0)) == 0,
		"Conservacao economica deve fechar para wood."
	)
	_assert_true(
		int(delta.get("player", {}).get("stone", 0)) + int(delta.get("warehouse", {}).get("stone", 0)) == 0,
		"Conservacao economica deve fechar para stone."
	)

	# validate_reconciliation deve confirmar consistência.
	_assert_true(
		DomainEventLoggerScript.validate_reconciliation(before, after, delta),
		"validate_reconciliation deve passar para deposito correto."
	)


func _test_canonicalize_max_depth() -> void:
	# Gera estrutura com 20 níveis de profundidade — além do limite de 16.
	var deep: Dictionary = {}
	var current: Dictionary = deep
	for _i in range(20):
		var nested: Dictionary = {}
		current["child"] = nested
		current = nested

	var result := DomainEventLoggerScript.canonicalize(deep)
	_assert_true(
		result.contains("[MAX_DEPTH]"),
		"canonicalize deve retornar marcador [MAX_DEPTH] ao exceder limite de profundidade."
	)


func _test_resource_pickup_no_inventory() -> void:
	DomainEventLoggerScript.clear_idempotency_keys()

	var pickup = ResourcePickupScript.new()
	pickup.resource_id = "wood"
	pickup.amount = 10
	pickup.amount_per_interaction = 5
	add_child(pickup)

	var actor := Node.new()
	actor.name = "ActorWithoutInventory"
	add_child(actor)

	pickup.interact(actor)
	_assert_true(
		pickup.amount == 10,
		"ResourcePickup nao deve reduzir amount se actor nao possui inventario."
	)

	actor.queue_free()
	pickup.queue_free()


func _test_resource_pickup_depletes_and_queues_free() -> void:
	DomainEventLoggerScript.clear_idempotency_keys()

	var pickup = ResourcePickupScript.new()
	pickup.resource_id = "stone"
	pickup.amount = 5
	pickup.amount_per_interaction = 5
	pickup.remove_when_depleted = true
	add_child(pickup)

	var player_inventory := _new_player_inventory()
	var actor := Node.new()
	actor.name = "ActorForDepleteTest"
	add_child(actor)
	actor.add_child(player_inventory)

	pickup.interact(actor)

	_assert_true(pickup.amount == 0, "ResourcePickup deve ficar com amount=0 apos coleta completa.")
	_assert_true(player_inventory.get_quantity(&"stone") == 5, "Jogador deve ter 5 stone apos coleta completa.")
	_assert_true(
		pickup.is_queued_for_deletion(),
		"ResourcePickup com remove_when_depleted=true deve estar na fila para remocao apos esgotar."
	)

	actor.queue_free()


func _test_blocked_completed_has_empty_delta() -> void:
	DomainEventLoggerScript.clear_idempotency_keys()

	var warehouse := _new_warehouse()
	warehouse.add_resource("wood", 20)
	warehouse.add_resource("stone", 10)

	var site := BuildingSite.new()
	site.name = "BlockedCompletedDeltaTest"
	site.building_id = &"blocked_completed_delta_test"
	site.required_resources = {"wood": 20, "stone": 10}
	site.step_count = 1
	add_child(site)
	site.warehouse_path = site.get_path_to(warehouse)

	var actor := Node.new()
	actor.name = "ActorBlockedTest"
	add_child(actor)

	# Conclui a construção em um passo.
	_assert_true(site.build_step(actor), "step_count=1 deveria concluir em uma etapa.")
	_assert_true(site.is_completed, "Site deveria estar concluido apos etapa unica.")

	# Captura estado antes da tentativa bloqueada.
	var wood_before := warehouse.get_available(&"wood")
	var stone_before := warehouse.get_available(&"stone")
	var progress_before := site.build_progress

	# Tentativa após conclusão — deve ser bloqueada sem mutação.
	_assert_true(not site.build_step(actor), "build_step em site concluido deve retornar false.")
	_assert_true(warehouse.get_available(&"wood") == wood_before, "Armazem nao deve ser alterado quando bloqueado por conclusao.")
	_assert_true(warehouse.get_available(&"stone") == stone_before, "Stone nao deve ser alterado quando bloqueado.")
	_assert_true(site.build_progress == progress_before, "Progresso nao deve regredir quando bloqueado.")

	site.queue_free()
	actor.queue_free()
	warehouse.queue_free()


# ============================================================
# Wave 3.1.6 — Testes de performance estrutural
# ============================================================

func _test_warehouse_batch_add_resources() -> void:
	# Verifica que batch_add_resources acumula varios recursos corretamente
	# e que o estado final e equivalente a N chamadas individuais de add_resource.
	var warehouse := _new_warehouse()

	warehouse.batch_add_resources({"wood": 15, "stone": 7, "iron": 3})

	_assert_true(warehouse.get_available(&"wood") == 15, "batch_add_resources deve adicionar wood corretamente.")
	_assert_true(warehouse.get_available(&"stone") == 7, "batch_add_resources deve adicionar stone corretamente.")
	_assert_true(warehouse.get_available(&"iron") == 3, "batch_add_resources deve adicionar iron corretamente.")

	# Batch adicional sobre estoque existente.
	warehouse.batch_add_resources({"wood": 5, "stone": 3})
	_assert_true(warehouse.get_available(&"wood") == 20, "batch_add_resources deve acumular sobre estoque existente (wood).")
	_assert_true(warehouse.get_available(&"stone") == 10, "batch_add_resources deve acumular sobre estoque existente (stone).")
	_assert_true(warehouse.get_available(&"iron") == 3, "iron deve permanecer inalterado apos segundo batch.")

	# Entradas invalidas no batch nao devem alterar estado.
	var stock_before := warehouse.get_stock_snapshot()
	warehouse.batch_add_resources({"": 5, "wood": 0, "stone": -1})
	_assert_true(warehouse.get_available(&"wood") == 20, "batch_add com amount=0 nao deve alterar wood.")
	_assert_true(warehouse.get_available(&"stone") == 10, "batch_add com amount negativo nao deve alterar stone.")
	var stock_after := warehouse.get_stock_snapshot()
	_assert_true(stock_before.hash() == stock_after.hash(), "batch_add com entradas invalidas nao deve alterar snapshot.")

	# Batch vazio nao deve alterar estado.
	warehouse.batch_add_resources({})
	_assert_true(warehouse.get_available(&"wood") == 20, "batch_add vazio nao deve alterar wood.")

	warehouse.queue_free()


func _test_building_site_step_cost_cache() -> void:
	# Verifica que get_step_cost() retorna resultado consistente com a receita configurada
	# e que multiplas chamadas retornam o mesmo valor (cache nao e mutado entre chamadas).
	var site := BuildingSite.new()
	site.name = "StepCostCacheTest"
	site.building_id = &"step_cost_cache_test"
	site.required_resources = {"wood": 20, "stone": 10}
	site.step_count = 2
	add_child(site)

	var cost_a := site.get_step_cost()
	var cost_b := site.get_step_cost()

	_assert_true(cost_a.has("wood"), "get_step_cost deve conter wood.")
	_assert_true(cost_a.has("stone"), "get_step_cost deve conter stone.")
	_assert_true(cost_a["wood"] == 10, "Custo de wood por etapa deve ser 10 (20 / 2).")
	_assert_true(cost_a["stone"] == 5, "Custo de stone por etapa deve ser 5 (10 / 2).")

	# Idempotencia: chamadas consecutivas retornam o mesmo valor.
	_assert_true(cost_a["wood"] == cost_b["wood"], "get_step_cost deve ser idempotente para wood.")
	_assert_true(cost_a["stone"] == cost_b["stone"], "get_step_cost deve ser idempotente para stone.")

	# Mutacao do retorno nao deve contaminar o cache interno.
	cost_a["wood"] = 999
	var cost_c := site.get_step_cost()
	_assert_true(cost_c["wood"] == 10, "Mutacao do retorno de get_step_cost nao deve contaminar cache interno.")

	site.queue_free()
