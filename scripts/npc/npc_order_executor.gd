class_name NPCOrderExecutor
extends RefCounted

const BUILD_INTERACTION_DISTANCE := 2.25
const BUILD_STEP_INTERVAL := 1.25
const GATHER_INTERACTION_DISTANCE := 1.8
const DROP_INTERACTION_DISTANCE := 1.8
const REPAIR_INTERACTION_DISTANCE := 2.25
const REPAIR_STEP_INTERVAL := 1.0
const REPAIR_AMOUNT_PER_STEP := 10.0
const COLLECTOR_TIMEOUT := 20.0
const PATROL_FALLBACK_OFFSET := Vector3(4.0, 0.0, 0.0)
const FOLLOW_TARGET_LOST_REASON := "FOLLOW_TARGET failed: target node is no longer valid."
const ASSIST_BUILD_NO_PENDING_REASON := "ASSIST_BUILD cancelado: nenhuma construção pendente encontrada."
const ASSIST_BUILD_NO_RESOURCES_REASON := "ASSIST_BUILD bloqueado: recursos insuficientes."

const COLLECTOR_FINDING_RESOURCE := "PROCURANDO_RECURSO"
const COLLECTOR_GOING_TO_GATHER := "INDO_COLETAR"
const COLLECTOR_COLLECTING := "COLETANDO"
const COLLECTOR_GOING_TO_DEPOSIT := "INDO_DEPOSITAR"
const COLLECTOR_DEPOSITING := "DEPOSITANDO"

var _npc: NPCBase = null
var _build_step_elapsed: float = 0.0
var _collector_state: String = ""
var _collector_state_elapsed: float = 0.0
var _collector_target: Node3D = null
var _collector_warehouse: Node3D = null
var _patrol_points: Array[Vector3] = []
var _patrol_index: int = 0
var _repair_step_elapsed: float = 0.0
var _collector_resource_filter: StringName = &""  # filtro de tipo para GATHER_RESOURCE


func setup(npc: NPCBase) -> void:
	_npc = npc


func start_order(order: NPCOrder) -> int:
	if _npc == null or order == null:
		return NPCEnums.OrderStatus.FAILED

	order.mark_started()
	_reset_runtime_state()
	_npc._log_order("started %s" % NPCEnums.order_type_to_string(order.order_type), order)

	var unsupported_reason := _validate_capability(order)
	if not unsupported_reason.is_empty():
		return _finish(order, NPCEnums.OrderStatus.UNSUPPORTED, unsupported_reason)

	match order.order_type:
		NPCEnums.OrderType.MOVE_TO_POSITION:
			if not order.target_position.is_finite():
				return _finish(order, NPCEnums.OrderStatus.FAILED, "MOVE_TO_POSITION failed: target_position is not finite.")
			_npc.tactical_state.reset_movement_modifiers()
			_npc._begin_semantic_move(order.target_position, NPCTacticalState.MOVING)
			return NPCEnums.OrderStatus.RUNNING
		NPCEnums.OrderType.FOLLOW_TARGET, NPCEnums.OrderType.FOLLOW_PLAYER:
			if not is_instance_valid(order.target_node):
				return _finish(order, NPCEnums.OrderStatus.FAILED, "FOLLOW_TARGET failed: target_node is invalid.")
			_npc.tactical_state.reset_movement_modifiers()
			_npc._begin_semantic_follow(order.target_node)
			return NPCEnums.OrderStatus.RUNNING
		NPCEnums.OrderType.HOLD_POSITION:
			_npc._enter_hold_position()
			return _finish(order, NPCEnums.OrderStatus.COMPLETED, "")
		NPCEnums.OrderType.ASSIST_BUILD:
			var assist_reason := _validate_build_target(order)
			if not assist_reason.is_empty():
				if assist_reason == ASSIST_BUILD_NO_PENDING_REASON:
					return _finish(order, NPCEnums.OrderStatus.COMPLETED, assist_reason)
				return _finish(order, NPCEnums.OrderStatus.FAILED, assist_reason)
			_npc.tactical_state.reset_movement_modifiers()
			if is_instance_valid(order.target_node):
				_npc._begin_semantic_move(order.target_node.global_position, NPCTacticalState.ASSISTING_BUILD)
			return NPCEnums.OrderStatus.RUNNING
		NPCEnums.OrderType.ATTACK_MOVE:
			if not order.target_position.is_finite():
				return _finish(order, NPCEnums.OrderStatus.FAILED, "ATTACK_MOVE failed: target_position is not finite.")
			_npc.tactical_state.reset_movement_modifiers()
			_npc._begin_semantic_move(order.target_position, NPCTacticalState.ATTACK_MOVE_PENDING)
			return NPCEnums.OrderStatus.RUNNING
		NPCEnums.OrderType.PATROL:
			return _start_patrol(order)
		NPCEnums.OrderType.FIRE_AT_WILL:
			_npc.tactical_state.reset_movement_modifiers()
			_npc.tactical_state.posture = NPCTacticalState.FIRE_AT_WILL
			_npc.tactical_state.set_state(NPCTacticalState.FIRE_AT_WILL)
			return _finish(order, NPCEnums.OrderStatus.PARTIAL, "FIRE_AT_WILL partial: combat target and damage system not implemented.")
		NPCEnums.OrderType.HOLD_FIRE:
			_npc.tactical_state.posture = NPCTacticalState.HOLD_FIRE
			_npc.tactical_state.blocks_auto_chase = true
			_npc.tactical_state.set_state(NPCTacticalState.HOLD_FIRE)
			return _finish(order, NPCEnums.OrderStatus.PARTIAL, "HOLD_FIRE partial: future automatic offense is blocked semantically.")
		NPCEnums.OrderType.FORM_SHIELD_WALL:
			_npc._enter_shield_wall_partial()
			return _finish(order, NPCEnums.OrderStatus.PARTIAL, "FORM_SHIELD_WALL partial: visual formation not implemented.")
		NPCEnums.OrderType.BRACE_PIKES:
			_npc._enter_braced_pikes_partial()
			return _finish(order, NPCEnums.OrderStatus.PARTIAL, "BRACE_PIKES partial: cavalry charge system not implemented.")
		NPCEnums.OrderType.GARRISON:
			return _start_garrison(order)
		NPCEnums.OrderType.FOCUS_FIRE:
			return _finish(order, NPCEnums.OrderStatus.UNSUPPORTED, "FOCUS_FIRE unsupported: combat target system not implemented.")
		NPCEnums.OrderType.VOLLEY_FIRE:
			return _finish(order, NPCEnums.OrderStatus.UNSUPPORTED, "VOLLEY_FIRE unsupported: ranged projectile system not implemented.")
		NPCEnums.OrderType.GATHER_RESOURCE:
			return _start_gather_resource(order)
		NPCEnums.OrderType.FORCE_DROP:
			return _start_force_drop(order)
		NPCEnums.OrderType.REPAIR:
			return _start_repair(order)
		NPCEnums.OrderType.REPAIR_UNDER_FIRE:
			return _finish(order, NPCEnums.OrderStatus.UNSUPPORTED, "REPAIR_UNDER_FIRE unsupported: threat-aware repair system not implemented.")
		NPCEnums.OrderType.MAN_SIEGE_RAM:
			return _finish(order, NPCEnums.OrderStatus.UNSUPPORTED, "MAN_SIEGE_RAM unsupported: siege engine interaction not implemented.")
		NPCEnums.OrderType.SCALE_WALLS:
			return _finish(order, NPCEnums.OrderStatus.UNSUPPORTED, "SCALE_WALLS unsupported: wall climbing system not implemented.")
		NPCEnums.OrderType.SAP_FOUNDATION:
			return _finish(order, NPCEnums.OrderStatus.UNSUPPORTED, "SAP_FOUNDATION unsupported: sapper/foundation system not implemented.")
		NPCEnums.OrderType.POUR_MURDER_HOLES:
			return _finish(order, NPCEnums.OrderStatus.UNSUPPORTED, "POUR_MURDER_HOLES unsupported: defensive structure trap system not implemented.")
		NPCEnums.OrderType.SALLY_OUT:
			return _finish(order, NPCEnums.OrderStatus.UNSUPPORTED, "SALLY_OUT unsupported: gate/threat/retreat system not implemented.")

	return _finish(order, NPCEnums.OrderStatus.UNSUPPORTED, "%s unsupported: semantic order has no executor branch." % NPCEnums.order_type_to_string(order.order_type))


func process_order(order: NPCOrder, delta: float) -> int:
	if _npc == null or order == null:
		return NPCEnums.OrderStatus.FAILED
	if _consume_navigation_failure():
		return _finish(order, NPCEnums.OrderStatus.FAILED, "Movement failed after stuck recovery attempts.")

	match order.order_type:
		NPCEnums.OrderType.MOVE_TO_POSITION:
			if _npc._semantic_has_arrived():
				return _finish(order, NPCEnums.OrderStatus.COMPLETED, "")
		NPCEnums.OrderType.FOLLOW_TARGET, NPCEnums.OrderType.FOLLOW_PLAYER:
			if not is_instance_valid(order.target_node):
				return _finish(order, NPCEnums.OrderStatus.FAILED, FOLLOW_TARGET_LOST_REASON)
			_npc._update_semantic_follow_target(order.target_node)
		NPCEnums.OrderType.ASSIST_BUILD:
			return _process_assist_build(order, delta)
		NPCEnums.OrderType.GATHER_RESOURCE:
			return _process_gather_resource(order, delta)
		NPCEnums.OrderType.FORCE_DROP:
			return _process_force_drop(order)
		NPCEnums.OrderType.REPAIR:
			return _process_repair(order, delta)
		NPCEnums.OrderType.ATTACK_MOVE:
			if _npc._semantic_has_arrived():
				return _finish(order, NPCEnums.OrderStatus.PARTIAL, "ATTACK_MOVE partial: movement completed, enemy scan/attack not implemented.")
		NPCEnums.OrderType.PATROL:
			return _process_patrol(order)

	return NPCEnums.OrderStatus.RUNNING


func cancel_order(order: NPCOrder, reason: String) -> void:
	if order == null:
		return
	order.mark_finished(NPCEnums.OrderStatus.CANCELLED, reason)
	_npc._stop_semantic_motion()
	_reset_runtime_state()
	_npc._log_order("cancelled %s: %s" % [NPCEnums.order_type_to_string(order.order_type), reason], order)


func _process_assist_build(order: NPCOrder, delta: float) -> int:
	# Se o alvo atual deixou de existir ou foi concluído, tenta redirecionar para o próximo site.
	if not _is_valid_incomplete_building_site(order.target_node):
		var next_site := _find_nearest_incomplete_building_site()
		if next_site == null:
			return _finish(order, NPCEnums.OrderStatus.COMPLETED, ASSIST_BUILD_NO_PENDING_REASON)
		# Redireciona para o próximo canteiro sem criar nova ordem.
		order.target_node = next_site
		_build_step_elapsed = 0.0
		_npc.tactical_state.reset_movement_modifiers()
		_npc._begin_semantic_move(order.target_node.global_position, NPCTacticalState.ASSISTING_BUILD)
		return NPCEnums.OrderStatus.RUNNING

	_npc._set_semantic_move_target(order.target_node.global_position)
	if not _npc._is_within_horizontal_distance(order.target_node.global_position, BUILD_INTERACTION_DISTANCE):
		_npc.tactical_state.blocks_auto_movement = false
		return NPCEnums.OrderStatus.RUNNING

	_npc.tactical_state.blocks_auto_movement = true
	_npc._stop_semantic_motion(false)
	_build_step_elapsed += delta
	if _build_step_elapsed < BUILD_STEP_INTERVAL:
		return NPCEnums.OrderStatus.RUNNING

	_build_step_elapsed = 0.0
	if order.target_node.has_method("can_build_step") and not bool(order.target_node.call("can_build_step", _npc)):
		if bool(order.target_node.get("is_completed")):
			# Concluído agora; loop vai redirecionar na próxima frame.
			return NPCEnums.OrderStatus.RUNNING
		return _finish(order, NPCEnums.OrderStatus.FAILED, _get_assist_build_block_reason(order.target_node))
	if not order.target_node.has_method("build_step"):
		return _finish(order, NPCEnums.OrderStatus.FAILED, "ASSIST_BUILD failed: target does not accept build progress.")

	var success := bool(order.target_node.call("build_step", _npc))
	if not success:
		if bool(order.target_node.get("is_completed")):
			return NPCEnums.OrderStatus.RUNNING
		return _finish(order, NPCEnums.OrderStatus.FAILED, _get_assist_build_block_reason(order.target_node))
	# build_step retornou true; se concluído agora, loop redireciona na próxima frame.
	if bool(order.target_node.get("is_completed")):
		var next_site_after_build := _find_nearest_incomplete_building_site()
		if next_site_after_build == null:
			return _finish(order, NPCEnums.OrderStatus.COMPLETED, ASSIST_BUILD_NO_PENDING_REASON)
		order.target_node = next_site_after_build
		_build_step_elapsed = 0.0
		_npc.tactical_state.reset_movement_modifiers()
		_npc._begin_semantic_move(order.target_node.global_position, NPCTacticalState.ASSISTING_BUILD)
	return NPCEnums.OrderStatus.RUNNING


func _start_gather_resource(order: NPCOrder) -> int:
	var inv := _get_actor_inventory()
	if inv == null:
		return _finish(order, NPCEnums.OrderStatus.FAILED, "GATHER_RESOURCE failed: NPC sem inventario proprio.")

	# Salva filtro de tipo para restringir coleta ao recurso designado (ex: "wood", "stone").
	# Se resource_id_filter == &"" (padrão), aceita qualquer pickup válido.
	_collector_resource_filter = order.resource_id_filter

	_collector_target = null
	if _is_valid_resource_pickup_for_filter(order.target_node, &""):
		var target_resource := StringName(String(order.target_node.get("resource_id")))
		if _collector_resource_filter == &"":
			_collector_resource_filter = target_resource
		if _is_valid_resource_pickup_for_filter(order.target_node, _collector_resource_filter):
			_collector_target = order.target_node as Node3D
		else:
			_npc._log("GATHER_RESOURCE ignored initial target: resource_id mismatch.")
	_npc._log("Coleta iniciada: %s" % _resource_filter_label(_collector_resource_filter))
	_npc.tactical_state.reset_movement_modifiers()
	if not inv.is_empty():
		_npc._log("Indo depositar recurso: %s" % _resource_filter_label(_collector_resource_filter))
		_set_collector_state(COLLECTOR_GOING_TO_DEPOSIT)
	elif _collector_target != null:
		_set_collector_state(COLLECTOR_GOING_TO_GATHER)
		_npc._begin_semantic_move(_collector_target.global_position, NPCTacticalState.MOVING)
	else:
		_set_collector_state(COLLECTOR_FINDING_RESOURCE)
	return NPCEnums.OrderStatus.RUNNING


func _process_gather_resource(order: NPCOrder, delta: float) -> int:
	var inv := _get_actor_inventory()
	if inv == null:
		return _finish(order, NPCEnums.OrderStatus.FAILED, "GATHER_RESOURCE failed: NPC sem inventario proprio.")

	_collector_state_elapsed += delta
	if _collector_state_elapsed > COLLECTOR_TIMEOUT and _collector_state in [COLLECTOR_GOING_TO_GATHER, COLLECTOR_GOING_TO_DEPOSIT]:
		return _finish(order, NPCEnums.OrderStatus.FAILED, "GATHER_RESOURCE failed: NPC bloqueado por timeout simples.")

	match _collector_state:
		COLLECTOR_FINDING_RESOURCE:
			if not inv.is_empty():
				_npc._log("Indo depositar recurso: %s" % _resource_filter_label(_collector_resource_filter))
				_set_collector_state(COLLECTOR_GOING_TO_DEPOSIT)
				return NPCEnums.OrderStatus.RUNNING
			_collector_target = _find_nearest_resource_pickup(_collector_resource_filter)
			if _collector_target == null:
				return _finish(order, NPCEnums.OrderStatus.COMPLETED, "GATHER_RESOURCE concluído: nenhum recurso restante do tipo %s." % _resource_filter_label(_collector_resource_filter))
			_set_collector_state(COLLECTOR_GOING_TO_GATHER)
			_npc._begin_semantic_move(_collector_target.global_position, NPCTacticalState.MOVING)
		COLLECTOR_GOING_TO_GATHER:
			if not _is_valid_resource_pickup_for_filter(_collector_target, _collector_resource_filter):
				_collector_target = null
				_set_collector_state(COLLECTOR_FINDING_RESOURCE)
				return NPCEnums.OrderStatus.RUNNING
			_npc._set_semantic_move_target(_collector_target.global_position)
			if _npc._is_within_horizontal_distance(_collector_target.global_position, GATHER_INTERACTION_DISTANCE):
				_set_collector_state(COLLECTOR_COLLECTING)
		COLLECTOR_COLLECTING:
			if not _is_valid_resource_pickup_for_filter(_collector_target, _collector_resource_filter):
				_collector_target = null
				_set_collector_state(COLLECTOR_FINDING_RESOURCE)
				return NPCEnums.OrderStatus.RUNNING
			_npc.tactical_state.blocks_auto_movement = true
			_npc._stop_semantic_motion(false)
			_collector_target.call("interact", _npc)
			_npc.tactical_state.blocks_auto_movement = false
			if inv.is_empty():
				_set_collector_state(COLLECTOR_FINDING_RESOURCE)
			else:
				_npc._log("Indo depositar recurso: %s" % _resource_filter_label(_collector_resource_filter))
				_set_collector_state(COLLECTOR_GOING_TO_DEPOSIT)
		COLLECTOR_GOING_TO_DEPOSIT:
			_collector_warehouse = _find_nearest_warehouse_interactable()
			if _collector_warehouse == null:
				return _finish(order, NPCEnums.OrderStatus.FAILED, "Coleta encerrada: nenhum armazem valido encontrado.")
			if _collector_state_elapsed <= delta + 0.0001:
				_npc._begin_semantic_move(_collector_warehouse.global_position, NPCTacticalState.MOVING)
			else:
				_npc._set_semantic_move_target(_collector_warehouse.global_position)
			if _npc._is_within_horizontal_distance(_collector_warehouse.global_position, DROP_INTERACTION_DISTANCE):
				_set_collector_state(COLLECTOR_DEPOSITING)
		COLLECTOR_DEPOSITING:
			if inv.is_empty():
				_set_collector_state(COLLECTOR_FINDING_RESOURCE)
				return NPCEnums.OrderStatus.RUNNING
			if not _is_valid_warehouse_interactable(_collector_warehouse):
				return _finish(order, NPCEnums.OrderStatus.FAILED, "Coleta encerrada: armazem alvo invalido.")
			_npc.tactical_state.blocks_auto_movement = true
			_npc._stop_semantic_motion(false)
			_collector_warehouse.call("interact", _npc)
			_npc.tactical_state.blocks_auto_movement = false
			if inv.is_empty():
				_npc._log("Deposito concluido; voltando a coletar: %s" % _resource_filter_label(_collector_resource_filter))
				_set_collector_state(COLLECTOR_FINDING_RESOURCE)
			else:
				return _finish(order, NPCEnums.OrderStatus.FAILED, "Coleta encerrada: armazem nao aceitou todos os recursos.")
		_:
			_set_collector_state(COLLECTOR_FINDING_RESOURCE)

	return NPCEnums.OrderStatus.RUNNING


func _start_force_drop(order: NPCOrder) -> int:
	var inv := _get_actor_inventory()
	if inv == null:
		return _finish(order, NPCEnums.OrderStatus.FAILED, "FORCE_DROP failed: NPC sem inventario proprio.")
	if inv.is_empty():
		return _finish(order, NPCEnums.OrderStatus.COMPLETED, "FORCE_DROP: inventario do ator esta vazio.")

	var target: Node3D = null
	if _is_valid_warehouse_interactable(order.target_node):
		target = order.target_node as Node3D
	else:
		target = _find_nearest_warehouse_interactable()
	if target == null:
		return _finish(order, NPCEnums.OrderStatus.FAILED, "FORCE_DROP failed: nenhum armazem valido encontrado.")

	order.target_node = target
	_npc.tactical_state.reset_movement_modifiers()
	_npc._begin_semantic_move(target.global_position, NPCTacticalState.MOVING)
	return NPCEnums.OrderStatus.RUNNING


func _process_force_drop(order: NPCOrder) -> int:
	if not _is_valid_warehouse_interactable(order.target_node):
		return _finish(order, NPCEnums.OrderStatus.FAILED, "FORCE_DROP failed: alvo nao e um armazem valido.")

	var inv := _get_actor_inventory()
	if inv == null:
		return _finish(order, NPCEnums.OrderStatus.FAILED, "FORCE_DROP failed: NPC sem inventario proprio.")
	if inv.is_empty():
		return _finish(order, NPCEnums.OrderStatus.COMPLETED, "FORCE_DROP: inventario do ator esta vazio.")

	var target := order.target_node as Node3D
	_npc._set_semantic_move_target(target.global_position)
	if not _npc._is_within_horizontal_distance(target.global_position, DROP_INTERACTION_DISTANCE):
		return NPCEnums.OrderStatus.RUNNING

	_npc.tactical_state.blocks_auto_movement = true
	_npc._stop_semantic_motion(false)
	target.call("interact", _npc)
	if inv.is_empty():
		return _finish(order, NPCEnums.OrderStatus.COMPLETED, "FORCE_DROP completed: recursos depositados no armazem.")
	return _finish(order, NPCEnums.OrderStatus.FAILED, "FORCE_DROP failed: armazem nao aceitou todos os recursos.")


func _start_patrol(order: NPCOrder) -> int:
	var point_a := _npc.global_position
	var point_b := order.target_position
	if order.target_position.is_finite() and order.secondary_target_position.is_finite():
		point_a = order.target_position
		point_b = order.secondary_target_position
	elif not point_b.is_finite():
		point_b = _npc.global_position + PATROL_FALLBACK_OFFSET
	if point_a.distance_to(point_b) < 0.25:
		point_b = point_a + PATROL_FALLBACK_OFFSET

	_patrol_points = [point_a, point_b]
	_patrol_index = 1
	_npc.tactical_state.reset_movement_modifiers()
	_npc._begin_semantic_move(_patrol_points[_patrol_index], NPCTacticalState.MOVING)
	return NPCEnums.OrderStatus.RUNNING


func _process_patrol(_order: NPCOrder) -> int:
	if _patrol_points.size() < 2:
		return NPCEnums.OrderStatus.FAILED
	if _npc._semantic_has_arrived():
		_patrol_index = 1 - _patrol_index
		_npc._begin_semantic_move(_patrol_points[_patrol_index], NPCTacticalState.MOVING)
	return NPCEnums.OrderStatus.RUNNING


func _start_repair(order: NPCOrder) -> int:
	if not _is_valid_repair_target(order.target_node):
		return _finish(order, NPCEnums.OrderStatus.FAILED, "REPAIR failed: alvo nao aceita reparo.")
	if not bool(order.target_node.call("is_damaged")):
		return _finish(order, NPCEnums.OrderStatus.COMPLETED, "REPAIR completed: construcao ja esta integra.")

	var target := order.target_node as Node3D
	_npc.tactical_state.reset_movement_modifiers()
	_npc._begin_semantic_move(target.global_position, NPCTacticalState.MOVING)
	return NPCEnums.OrderStatus.RUNNING


func _process_repair(order: NPCOrder, delta: float) -> int:
	if not _is_valid_repair_target(order.target_node):
		return _finish(order, NPCEnums.OrderStatus.FAILED, "REPAIR failed: alvo de reparo invalido.")
	if not bool(order.target_node.call("is_damaged")):
		return _finish(order, NPCEnums.OrderStatus.COMPLETED, "REPAIR completed: construcao reparada.")

	var target := order.target_node as Node3D
	_npc._set_semantic_move_target(target.global_position)
	if not _npc._is_within_horizontal_distance(target.global_position, REPAIR_INTERACTION_DISTANCE):
		return NPCEnums.OrderStatus.RUNNING

	_npc.tactical_state.blocks_auto_movement = true
	_npc._stop_semantic_motion(false)
	_repair_step_elapsed += delta
	if _repair_step_elapsed < REPAIR_STEP_INTERVAL:
		return NPCEnums.OrderStatus.RUNNING

	_repair_step_elapsed = 0.0
	order.target_node.call("repair", REPAIR_AMOUNT_PER_STEP)
	if not bool(order.target_node.call("is_damaged")):
		return _finish(order, NPCEnums.OrderStatus.COMPLETED, "REPAIR completed: construcao reparada.")
	return NPCEnums.OrderStatus.RUNNING


func _validate_capability(order: NPCOrder) -> String:
	if _npc.capabilities == null:
		return "CapabilitySet missing."
	if _npc.capabilities.supports(order.order_type):
		return ""
	return "%s unsupported: NPC lacks required capability." % NPCEnums.order_type_to_string(order.order_type)


func _validate_build_target(order: NPCOrder) -> String:
	if _is_valid_incomplete_building_site(order.target_node):
		return ""
	var next_site := _find_nearest_incomplete_building_site()
	if next_site != null:
		order.target_node = next_site
		return ""
	if is_instance_valid(order.target_node) and not _is_building_site(order.target_node):
		return "ASSIST_BUILD failed: target does not accept build progress."
	return ASSIST_BUILD_NO_PENDING_REASON


func _get_assist_build_block_reason(target: Node) -> String:
	if is_instance_valid(target) and target.has_method("get_build_block_reason"):
		var reason := String(target.call("get_build_block_reason", _npc))
		if not reason.is_empty():
			return reason
	return ASSIST_BUILD_NO_RESOURCES_REASON


func _start_garrison(order: NPCOrder) -> int:
	if not is_instance_valid(order.target_node):
		return _finish(order, NPCEnums.OrderStatus.FAILED, "GARRISON failed: target_node is invalid.")
	if order.target_node.has_method("garrison") or order.target_node.has_method("add_garrisoned_unit") or bool(order.target_node.get("supports_garrison")):
		_npc.tactical_state.set_state(NPCTacticalState.GARRISON_PENDING)
		return _finish(order, NPCEnums.OrderStatus.PARTIAL, "GARRISON partial: compatible target detected, transfer/occupancy system not implemented.")
	return _finish(order, NPCEnums.OrderStatus.UNSUPPORTED, "GARRISON unsupported: target does not expose garrison support.")


func _finish(order: NPCOrder, status: int, reason: String) -> int:
	order.mark_finished(status, reason)
	match status:
		NPCEnums.OrderStatus.COMPLETED:
			_npc._log_order("completed %s" % NPCEnums.order_type_to_string(order.order_type), order)
		NPCEnums.OrderStatus.FAILED:
			_npc._log_order("FAILED %s: %s" % [NPCEnums.order_type_to_string(order.order_type), reason], order)
		NPCEnums.OrderStatus.UNSUPPORTED:
			_npc.tactical_state.set_state(NPCTacticalState.UNSUPPORTED_ORDER, reason)
			_npc._log_order("UNSUPPORTED %s: %s" % [NPCEnums.order_type_to_string(order.order_type), reason], order)
		NPCEnums.OrderStatus.PARTIAL:
			_npc._log_order("PARTIAL %s: %s" % [NPCEnums.order_type_to_string(order.order_type), reason], order)
	_reset_runtime_state()
	return status


func _reset_runtime_state() -> void:
	_build_step_elapsed = 0.0
	_collector_state = ""
	_collector_state_elapsed = 0.0
	_collector_target = null
	_collector_warehouse = null
	_collector_resource_filter = &""
	_patrol_points.clear()
	_patrol_index = 0
	_repair_step_elapsed = 0.0


func _set_collector_state(state: String) -> void:
	_collector_state = state
	_collector_state_elapsed = 0.0
	_npc.tactical_state.set_state(state)


func _get_actor_inventory() -> InventoryContainer:
	if _npc != null and _npc.has_method("get_inventory"):
		var inv: Variant = _npc.call("get_inventory")
		if inv is InventoryContainer:
			return inv
	return null


func _find_nearest_resource_pickup(resource_filter: StringName = &"") -> Node3D:
	var best: Node3D = null
	var best_distance := INF
	for node in _npc.get_tree().get_nodes_in_group("resource_pickup"):
		if not _is_valid_resource_pickup_for_filter(node, resource_filter):
			continue
		var node3d := node as Node3D
		var distance := node3d.global_position.distance_to(_npc.global_position)
		if distance < best_distance:
			best = node3d
			best_distance = distance
	return best


func _find_nearest_warehouse_interactable() -> Node3D:
	var default_warehouse := _find_nearest_group_node(&"warehouse_interactable", Callable(self, "_is_default_operational_warehouse"))
	if default_warehouse != null:
		return default_warehouse
	return _find_nearest_group_node(&"warehouse_interactable", Callable(self, "_is_operational_warehouse"))


func _find_nearest_incomplete_building_site() -> Node3D:
	return _find_nearest_group_node(&"building_site", Callable(self, "_is_valid_incomplete_building_site"))


func _find_nearest_group_node(group_name: StringName, predicate: Callable) -> Node3D:
	var best: Node3D = null
	var best_distance := INF
	for node in _npc.get_tree().get_nodes_in_group(group_name):
		if not (node is Node3D):
			continue
		if not predicate.call(node):
			continue
		var node3d := node as Node3D
		var distance := node3d.global_position.distance_to(_npc.global_position)
		if distance < best_distance:
			best = node3d
			best_distance = distance
	return best


func _is_valid_resource_pickup(node: Variant) -> bool:
	return _is_valid_resource_pickup_for_filter(node, &"")


func _is_valid_resource_pickup_for_filter(node: Variant, resource_filter: StringName) -> bool:
	if node == null:
		return false

	var object := node as Object
	if object == null or not is_instance_valid(object):
		return false

	var node_ref := object as Node
	if node_ref == null or not (node_ref is Node3D):
		return false
	if not (_has_property(node_ref, "resource_id") and _has_property(node_ref, "amount") and node_ref.has_method("interact")):
		return false
	if int(node_ref.get("amount")) <= 0:
		return false
	# Aplica filtro de tipo: só aceita pickup se o resource_id coincidir com o filtro ativo.
	if resource_filter != &"":
		return StringName(String(node_ref.get("resource_id"))) == resource_filter
	return true


func _is_valid_warehouse_interactable(node: Node) -> bool:
	return _is_operational_warehouse(node)


func _is_operational_warehouse(node: Node) -> bool:
	if not is_instance_valid(node) or not (node is Node3D):
		return false
	if _is_building_site(node):
		return false
	var node3d := node as Node3D
	if not node3d.visible:
		return false
	if not node.has_method("interact"):
		return false
	if node.has_method("get_warehouse"):
		return node.call("get_warehouse") is Warehouse
	return _has_property(node, "warehouse_path")


func _is_default_operational_warehouse(node: Node) -> bool:
	if not _is_operational_warehouse(node):
		return false
	if not node.has_method("get_warehouse"):
		return false
	var warehouse := node.call("get_warehouse") as Warehouse
	return warehouse != null and warehouse.warehouse_id == &"warehouse_default"


func _is_incomplete_building_site(node: Node) -> bool:
	if not is_instance_valid(node) or not (node is Node3D):
		return false
	# Aceita qualquer nó que suporte build_step e ainda não esteja concluído.
	return node.has_method("build_step") and not bool(node.get("is_completed"))


func _is_valid_repair_target(node: Node) -> bool:
	return is_instance_valid(node) and node is Node3D and node.has_method("is_damaged") and node.has_method("repair")


func _is_building_site(node: Node) -> bool:
	if not is_instance_valid(node) or not (node is Node3D):
		return false
	return node.has_method("build_step") and _has_property(node, "is_completed")


func _is_valid_incomplete_building_site(node: Node) -> bool:
	if not _is_building_site(node):
		return false
	var node3d := node as Node3D
	if not node3d.visible:
		return false
	if _is_operational_warehouse(node):
		return false
	return not bool(node.get("is_completed"))


func _consume_navigation_failure() -> bool:
	if _npc != null and _npc.has_method("consume_navigation_failure"):
		return bool(_npc.call("consume_navigation_failure"))
	return false


func _resource_filter_label(resource_filter: StringName) -> String:
	return String(resource_filter) if resource_filter != &"" else "any"


func _has_property(node: Object, property_name: String) -> bool:
	for property in node.get_property_list():
		if String(property.get("name", "")) == property_name:
			return true
	return false
