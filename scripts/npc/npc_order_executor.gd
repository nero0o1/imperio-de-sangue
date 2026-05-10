class_name NPCOrderExecutor
extends RefCounted

const BUILD_INTERACTION_DISTANCE := 2.25
const BUILD_STEP_INTERVAL := 1.25
const GATHER_INTERACTION_DISTANCE := 1.8
const DROP_INTERACTION_DISTANCE := 1.8
const FOLLOW_TARGET_LOST_REASON := "FOLLOW_TARGET failed: target node is no longer valid."

var _npc: NPCBase = null
var _build_step_elapsed: float = 0.0


func setup(npc: NPCBase) -> void:
	_npc = npc


func start_order(order: NPCOrder) -> int:
	if _npc == null or order == null:
		return NPCEnums.OrderStatus.FAILED

	order.mark_started()
	_build_step_elapsed = 0.0
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
				return _finish(order, NPCEnums.OrderStatus.FAILED, assist_reason)
			_npc.tactical_state.reset_movement_modifiers()
			_npc._begin_semantic_move(order.target_node.global_position, NPCTacticalState.ASSISTING_BUILD)
			return NPCEnums.OrderStatus.RUNNING
		NPCEnums.OrderType.ATTACK_MOVE:
			if not order.target_position.is_finite():
				return _finish(order, NPCEnums.OrderStatus.FAILED, "ATTACK_MOVE failed: target_position is not finite.")
			_npc.tactical_state.reset_movement_modifiers()
			_npc._begin_semantic_move(order.target_position, NPCTacticalState.ATTACK_MOVE_PENDING)
			return NPCEnums.OrderStatus.RUNNING
		NPCEnums.OrderType.PATROL:
			_npc.tactical_state.reset_movement_modifiers()
			_npc._begin_semantic_move(order.target_position, NPCTacticalState.MOVING)
			return NPCEnums.OrderStatus.RUNNING
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
			return _finish(order, NPCEnums.OrderStatus.UNSUPPORTED, "REPAIR unsupported: repairable damage system not implemented.")
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
			return _process_gather_resource(order)
		NPCEnums.OrderType.FORCE_DROP:
			return _process_force_drop(order)
		NPCEnums.OrderType.ATTACK_MOVE:
			if _npc._semantic_has_arrived():
				return _finish(order, NPCEnums.OrderStatus.PARTIAL, "ATTACK_MOVE partial: movement completed, enemy scan/attack not implemented.")
		NPCEnums.OrderType.PATROL:
			if _npc._semantic_has_arrived():
				return _finish(order, NPCEnums.OrderStatus.PARTIAL, "PATROL partial: single patrol point reached, route loop not implemented.")

	return NPCEnums.OrderStatus.RUNNING


func cancel_order(order: NPCOrder, reason: String) -> void:
	if order == null:
		return
	order.mark_finished(NPCEnums.OrderStatus.CANCELLED, reason)
	_npc._stop_semantic_motion()
	_npc._log_order("cancelled %s: %s" % [NPCEnums.order_type_to_string(order.order_type), reason], order)


func _process_assist_build(order: NPCOrder, delta: float) -> int:
	if not is_instance_valid(order.target_node):
		return _finish(order, NPCEnums.OrderStatus.FAILED, "ASSIST_BUILD failed: target node is no longer valid.")
	if bool(order.target_node.get("is_completed")):
		return _finish(order, NPCEnums.OrderStatus.COMPLETED, "ASSIST_BUILD completed: target construction is already complete.")

	_npc._set_semantic_move_target(order.target_node.global_position)
	if not _npc._is_within_horizontal_distance(order.target_node.global_position, BUILD_INTERACTION_DISTANCE):
		# Still approaching: ensure legacy movement is not blocked while closing distance.
		_npc.tactical_state.blocks_auto_movement = false
		return NPCEnums.OrderStatus.RUNNING

	# Within build range: block legacy _process_move_to_position so it cannot fight the
	# manual stop below. blocks_auto_movement is reset by reset_movement_modifiers() on finish.
	_npc.tactical_state.blocks_auto_movement = true
	_npc._stop_semantic_motion(false)
	_build_step_elapsed += delta
	if _build_step_elapsed < BUILD_STEP_INTERVAL:
		return NPCEnums.OrderStatus.RUNNING

	_build_step_elapsed = 0.0
	if order.target_node.has_method("can_build_step") and not bool(order.target_node.call("can_build_step", _npc)):
		if bool(order.target_node.get("is_completed")):
			return _finish(order, NPCEnums.OrderStatus.COMPLETED, "ASSIST_BUILD completed: construction finished.")
		return _finish(order, NPCEnums.OrderStatus.FAILED, "ASSIST_BUILD failed: target cannot accept build progress now.")
	if not order.target_node.has_method("build_step"):
		return _finish(order, NPCEnums.OrderStatus.FAILED, "ASSIST_BUILD failed: target does not accept build progress.")

	var success := bool(order.target_node.call("build_step", _npc))
	if not success:
		if bool(order.target_node.get("is_completed")):
			return _finish(order, NPCEnums.OrderStatus.COMPLETED, "ASSIST_BUILD completed: construction finished.")
		return _finish(order, NPCEnums.OrderStatus.FAILED, "ASSIST_BUILD failed: build_step returned false.")
	if bool(order.target_node.get("is_completed")):
		return _finish(order, NPCEnums.OrderStatus.COMPLETED, "ASSIST_BUILD completed: construction finished.")
	return NPCEnums.OrderStatus.RUNNING


## MVP: NPC vai até o pickup e chama interact(npc) ao chegar.
## ResourcePickup encontra o NpcInventory via get_inventory() e coleta o recurso.
func _start_gather_resource(order: NPCOrder) -> int:
	if not is_instance_valid(order.target_node):
		return _finish(order, NPCEnums.OrderStatus.FAILED, "GATHER_RESOURCE failed: no target pickup specified.")
	if not order.target_node.has_method("interact"):
		return _finish(order, NPCEnums.OrderStatus.FAILED, "GATHER_RESOURCE failed: target has no interact() method.")
	var inv := _npc.get_inventory() if _npc.has_method("get_inventory") else null
	if inv == null:
		return _finish(order, NPCEnums.OrderStatus.PARTIAL, "GATHER_RESOURCE partial: NPC has no inventory — cannot carry resources.")
	_npc.tactical_state.reset_movement_modifiers()
	_npc._begin_semantic_move(order.target_node.global_position, NPCTacticalState.MOVING)
	return NPCEnums.OrderStatus.RUNNING


func _process_gather_resource(order: NPCOrder) -> int:
	if not is_instance_valid(order.target_node):
		return _finish(order, NPCEnums.OrderStatus.FAILED, "GATHER_RESOURCE failed: target pickup no longer valid (depleted?).")
	_npc._set_semantic_move_target(order.target_node.global_position)
	if not _npc._is_within_horizontal_distance(order.target_node.global_position, GATHER_INTERACTION_DISTANCE):
		return NPCEnums.OrderStatus.RUNNING
	# Dentro do alcance: interagir e coletar.
	_npc.tactical_state.blocks_auto_movement = true
	_npc._stop_semantic_motion(false)
	order.target_node.call("interact", _npc)
	return _finish(order, NPCEnums.OrderStatus.COMPLETED, "GATHER_RESOURCE completed: interacted with pickup.")


## MVP: NPC vai até o WarehouseInteractable e chama interact(npc) ao chegar.
## WarehouseInteractable encontra o NpcInventory via get_inventory() e deposita tudo.
func _start_force_drop(order: NPCOrder) -> int:
	if not is_instance_valid(order.target_node):
		return _finish(order, NPCEnums.OrderStatus.FAILED, "FORCE_DROP failed: no target warehouse specified.")
	if not order.target_node.has_method("interact"):
		return _finish(order, NPCEnums.OrderStatus.FAILED, "FORCE_DROP failed: target has no interact() method.")
	var inv := _npc.get_inventory() if _npc.has_method("get_inventory") else null
	if inv == null:
		return _finish(order, NPCEnums.OrderStatus.PARTIAL, "FORCE_DROP partial: NPC has no inventory.")
	_npc.tactical_state.reset_movement_modifiers()
	_npc._begin_semantic_move(order.target_node.global_position, NPCTacticalState.MOVING)
	return NPCEnums.OrderStatus.RUNNING


func _process_force_drop(order: NPCOrder) -> int:
	if not is_instance_valid(order.target_node):
		return _finish(order, NPCEnums.OrderStatus.FAILED, "FORCE_DROP failed: target warehouse no longer valid.")
	_npc._set_semantic_move_target(order.target_node.global_position)
	if not _npc._is_within_horizontal_distance(order.target_node.global_position, DROP_INTERACTION_DISTANCE):
		return NPCEnums.OrderStatus.RUNNING
	# Dentro do alcance: depositar.
	_npc.tactical_state.blocks_auto_movement = true
	_npc._stop_semantic_motion(false)
	order.target_node.call("interact", _npc)
	return _finish(order, NPCEnums.OrderStatus.COMPLETED, "FORCE_DROP completed: deposited resources to warehouse.")


func _validate_capability(order: NPCOrder) -> String:
	if _npc.capabilities == null:
		return "CapabilitySet missing."
	if _npc.capabilities.supports(order.order_type):
		return ""
	return "%s unsupported: NPC lacks required capability." % NPCEnums.order_type_to_string(order.order_type)


func _validate_build_target(order: NPCOrder) -> String:
	if not is_instance_valid(order.target_node):
		return "ASSIST_BUILD failed: target_node is invalid."
	if bool(order.target_node.get("is_completed")):
		return "ASSIST_BUILD failed: target construction is already complete."
	if not order.target_node.has_method("build_step"):
		return "ASSIST_BUILD failed: target does not accept build progress."
	return ""


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
	return status
