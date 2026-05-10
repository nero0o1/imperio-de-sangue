class_name NPCBase
extends CharacterBody3D

signal selection_changed(npc: NPCBase, is_selected: bool)

@export var npc_name: String = "Civil NPC"
@export_enum("CIVIL", "SOLDIER", "HOSTILE") var role: int = NPCEnums.Role.CIVIL
@export_enum("PLAYER", "ENEMY", "NEUTRAL") var faction: int = NPCEnums.Faction.PLAYER
@export_enum("IDLE", "SELECTED", "MOVING", "FOLLOWING", "BLOCKED", "HOLDING_POSITION") var current_state: int = NPCEnums.State.IDLE
@export var movement_speed: float = 3.0
@export var shield_wall_speed_multiplier: float = 0.45
@export var follow_distance: float = 2.0
@export var arrival_distance: float = 0.25
@export var selected: bool = false
@export var debug_enabled: bool = true
@export var idle_wander_enabled: bool = true
@export var idle_wander_radius: float = 1.5
@export var idle_wander_interval_min: float = 2.5
@export var idle_wander_interval_max: float = 5.0
@export var idle_wander_arrival_distance: float = 0.35

var current_order: NPCOrder = null
var order_queue: NPCOrderQueue = NPCOrderQueue.new()
var order_executor: NPCOrderExecutor = NPCOrderExecutor.new()
var capabilities: NPCCapabilitySet = NPCCapabilitySet.new()
var tactical_state: NPCTacticalState = NPCTacticalState.new()

var _target_position: Vector3 = Vector3.ZERO
var _use_navigation_agent := false
var _logged_movement_fallback := false
var _semantic_motion_active := false
# Inventário próprio do NPC para coleta e depósito de recursos.
var _npc_inventory: NpcInventory = null
var _idle_anchor: Vector3 = Vector3.ZERO
var _idle_target: Vector3 = Vector3.ZERO
var _idle_wait_elapsed := 0.0
var _idle_wait_duration := 0.0
var _idle_has_target := false

@onready var _selection_indicator: Node3D = get_node_or_null("SelectionIndicator") as Node3D
@onready var _navigation_agent: NavigationAgent3D = get_node_or_null("NavigationAgent3D") as NavigationAgent3D
@onready var _name_label: Label3D = get_node_or_null("NameLabel") as Label3D


func _ready() -> void:
	add_to_group("npc")
	current_state = NPCEnums.State.IDLE
	capabilities.configure_for_role(role)
	order_executor.setup(self)
	current_order = null
	_target_position = global_position
	_idle_anchor = global_position
	_idle_target = global_position
	_idle_wait_duration = _next_idle_wait()
	_configure_navigation_agent()
	_update_selection_visual()
	_update_name_label()
	_setup_npc_inventory()
	_log("NPC criado: %s role=%s faction=%s." % [
		npc_name,
		NPCEnums.role_to_string(role),
		NPCEnums.faction_to_string(faction),
	])
	_log("Estado inicial: %s." % NPCEnums.state_to_string(current_state))


func _physics_process(delta: float) -> void:
	if _process_semantic_order(delta):
		return

	match current_state:
		NPCEnums.State.MOVING:
			_process_move_to_position(delta)
		NPCEnums.State.FOLLOWING:
			_process_following(delta)
		NPCEnums.State.IDLE:
			_process_idle_wander(delta)
		_:
			_reset_idle_wander_if_busy()


func select() -> void:
	for node in get_tree().get_nodes_in_group("npc"):
		if node != self and node is NPCBase:
			node.deselect()

	if selected:
		return

	selected = true
	_update_selection_visual()
	if current_state == NPCEnums.State.IDLE:
		set_state(NPCEnums.State.SELECTED)
	selection_changed.emit(self, true)
	_log("Selecionado: %s." % npc_name)


func deselect() -> void:
	var was_selected := selected
	if not was_selected and current_state != NPCEnums.State.SELECTED:
		return

	selected = false
	_update_selection_visual()
	if current_state == NPCEnums.State.SELECTED:
		set_state(NPCEnums.State.IDLE)
	if was_selected:
		selection_changed.emit(self, false)
		_log("Desselecionado: %s." % npc_name)


func set_role(new_role: int) -> void:
	role = new_role
	if capabilities != null:
		capabilities.configure_for_role(role)
	_log("Role alterada: %s." % NPCEnums.role_to_string(role))


func set_faction(new_faction: int) -> void:
	faction = new_faction
	_log("Faction alterada: %s." % NPCEnums.faction_to_string(faction))


func set_state(new_state: int) -> void:
	if current_state == new_state:
		return

	var previous_state := current_state
	current_state = new_state
	_log("Mudanca de estado: %s -> %s." % [
		NPCEnums.state_to_string(previous_state),
		NPCEnums.state_to_string(current_state),
	])


func issue_order(new_order: NPCOrder) -> bool:
	if new_order == null or not new_order.is_valid():
		_log_order("FAILED invalid order received", new_order)
		return false

	_log_order("received %s" % NPCEnums.order_type_to_string(new_order.order_type), new_order)
	match new_order.order_type:
		NPCEnums.OrderType.STOP:
			_apply_stop_order(new_order)
			return true
		NPCEnums.OrderType.CLEAR_QUEUE:
			_apply_clear_queue_order(new_order)
			return true

	if new_order.queue and order_queue.has_current_order():
		order_queue.enqueue(new_order)
		_log_order("accepted PENDING %s" % NPCEnums.order_type_to_string(new_order.order_type), new_order)
		_log_order("queue changed pending=%d" % order_queue.pending_orders.size(), new_order)
		return true

	_cancel_current_order("Replaced by %s." % NPCEnums.order_type_to_string(new_order.order_type))
	for cancelled in order_queue.clear_pending("Cleared by new non-queued order."):
		_log_order("cancelled pending %s" % NPCEnums.order_type_to_string(cancelled.order_type), cancelled)

	order_queue.current_order = new_order
	current_order = new_order
	_log_order("accepted %s" % NPCEnums.order_type_to_string(new_order.order_type), new_order)
	_start_current_order()
	return true


func clear_order() -> void:
	current_order = null
	order_queue.current_order = null
	_target_position = global_position
	_semantic_motion_active = false
	if _navigation_agent != null:
		_navigation_agent.target_position = global_position


func move_to_position(destination: Vector3) -> void:
	issue_move_order(destination)


func follow_target(target_node: Node3D) -> void:
	issue_follow_order(target_node)


func stop_current_order() -> void:
	issue_stop_order()


func issue_move_order(destination: Vector3, queue: bool = false) -> bool:
	return issue_order(NPCOrder.move_to_position(destination, self, queue))


func issue_stop_order() -> bool:
	return issue_order(NPCOrder.stop(self))


func issue_hold_position_order() -> bool:
	return issue_order(NPCOrder.hold_position(self))


func issue_follow_order(target: Node3D, queue: bool = false) -> bool:
	return issue_order(NPCOrder.follow_target(target, self, queue))


func issue_assist_build_order(building_site: Node3D, queue: bool = false) -> bool:
	return issue_order(NPCOrder.assist_build(building_site, self, queue))


func issue_test_order_by_type(type: int) -> bool:
	return issue_order(NPCOrder.make(type, global_position, null, self))


func is_busy() -> bool:
	return current_state == NPCEnums.State.MOVING or current_state == NPCEnums.State.FOLLOWING


func get_debug_status() -> String:
	return "[NPC] %s state=%s tactical=%s role=%s faction=%s selected=%s order=%s pending=%d" % [
		npc_name,
		NPCEnums.state_to_string(current_state),
		tactical_state.state if tactical_state != null else "none",
		NPCEnums.role_to_string(role),
		NPCEnums.faction_to_string(faction),
		str(selected),
		current_order.get_debug_summary() if current_order != null else "none",
		order_queue.pending_orders.size(),
	]


func interact(actor: Node = null) -> void:
	select()
	_log("interact(actor) recebido de %s." % (str(actor.name) if actor != null else "unknown"))


func _process_semantic_order(delta: float) -> bool:
	if current_order == null or current_order.status != NPCEnums.OrderStatus.RUNNING:
		return false

	var result := order_executor.process_order(current_order, delta)
	if result != NPCEnums.OrderStatus.RUNNING:
		_complete_current_order(result, current_order.failure_reason)
		return true
	return false


func _start_current_order() -> void:
	if current_order == null:
		return

	var result := order_executor.start_order(current_order)
	if result != NPCEnums.OrderStatus.RUNNING:
		_complete_current_order(result, current_order.failure_reason)


func _complete_current_order(status: int, reason: String = "") -> void:
	var finished := order_queue.finish_current(status, reason)
	current_order = null
	_semantic_motion_active = false
	if finished != null and status != NPCEnums.OrderStatus.PARTIAL and finished.order_type != NPCEnums.OrderType.HOLD_POSITION:
		tactical_state.reset_movement_modifiers()
	if status in [NPCEnums.OrderStatus.COMPLETED, NPCEnums.OrderStatus.FAILED, NPCEnums.OrderStatus.CANCELLED, NPCEnums.OrderStatus.UNSUPPORTED, NPCEnums.OrderStatus.PARTIAL]:
		if current_state == NPCEnums.State.MOVING or current_state == NPCEnums.State.FOLLOWING:
			set_state(NPCEnums.State.SELECTED if selected else NPCEnums.State.IDLE)
	_start_next_order_if_available()


func _start_next_order_if_available() -> void:
	var next_order := order_queue.start_next()
	current_order = next_order
	if next_order == null:
		return
	_log_order("next order started %s" % NPCEnums.order_type_to_string(next_order.order_type), next_order)
	_start_current_order()


func _cancel_current_order(reason: String) -> void:
	if current_order == null:
		return
	order_executor.cancel_order(current_order, reason)
	order_queue.current_order = null
	current_order = null
	_stop_semantic_motion()


func _apply_stop_order(order: NPCOrder) -> void:
	# STOP is an emergency interrupt in this prototype: it cancels the current order
	# and clears all pending orders so no queued movement restarts after the stop.
	_cancel_current_order("STOP issued.")
	for cancelled in order_queue.clear_pending("Cleared by STOP."):
		_log_order("cancelled pending %s" % NPCEnums.order_type_to_string(cancelled.order_type), cancelled)
	order.mark_finished(NPCEnums.OrderStatus.COMPLETED, "STOP completed: current order cancelled and queue cleared.")
	_stop_semantic_motion()
	tactical_state.reset_movement_modifiers()
	tactical_state.set_state(NPCTacticalState.IDLE)
	set_state(NPCEnums.State.SELECTED if selected else NPCEnums.State.IDLE)
	_log_order("completed STOP", order)
	_log_order("queue changed pending=0", order)


func _apply_clear_queue_order(order: NPCOrder) -> void:
	# CLEAR_QUEUE only removes pending orders. The active order keeps running.
	for cancelled in order_queue.clear_pending("Cleared by CLEAR_QUEUE."):
		_log_order("cancelled pending %s" % NPCEnums.order_type_to_string(cancelled.order_type), cancelled)
	order.mark_finished(NPCEnums.OrderStatus.COMPLETED, "CLEAR_QUEUE completed: pending orders cleared, current order preserved.")
	_log_order("completed CLEAR_QUEUE", order)
	_log_order("queue changed pending=0", order)


func _begin_semantic_move(destination: Vector3, tactical: String) -> void:
	if not destination.is_finite():
		set_state(NPCEnums.State.BLOCKED)
		return

	_target_position = destination
	_semantic_motion_active = true
	tactical_state.set_state(tactical)
	if _use_navigation_agent:
		_navigation_agent.target_position = destination
	else:
		_log_movement_fallback_once()
	set_state(NPCEnums.State.MOVING)


func _begin_semantic_follow(target_node: Node3D) -> void:
	if not is_instance_valid(target_node):
		set_state(NPCEnums.State.BLOCKED)
		return
	_semantic_motion_active = true
	tactical_state.set_state(NPCTacticalState.FOLLOWING)
	if not _use_navigation_agent:
		_log_movement_fallback_once()
	set_state(NPCEnums.State.FOLLOWING)


func _update_semantic_follow_target(target_node: Node3D) -> void:
	if not is_instance_valid(target_node):
		return
	_target_position = target_node.global_position


func _set_semantic_move_target(destination: Vector3) -> void:
	_target_position = destination
	if _use_navigation_agent:
		_navigation_agent.target_position = destination


func _stop_semantic_motion(reset_target: bool = true) -> void:
	velocity = Vector3.ZERO
	_semantic_motion_active = false
	if reset_target:
		_target_position = global_position
		if _navigation_agent != null:
			_navigation_agent.target_position = global_position


func _enter_hold_position() -> void:
	_stop_semantic_motion()
	tactical_state.blocks_auto_chase = true
	tactical_state.blocks_auto_movement = true
	tactical_state.set_state(NPCTacticalState.HOLDING_POSITION)
	set_state(NPCEnums.State.HOLDING_POSITION)


func _enter_shield_wall_partial() -> void:
	_stop_semantic_motion()
	tactical_state.blocks_auto_chase = true
	tactical_state.speed_multiplier = shield_wall_speed_multiplier
	tactical_state.set_state(NPCTacticalState.SHIELD_WALL_PARTIAL)
	set_state(NPCEnums.State.HOLDING_POSITION)


func _enter_braced_pikes_partial() -> void:
	_stop_semantic_motion()
	tactical_state.blocks_auto_chase = true
	tactical_state.blocks_auto_movement = true
	tactical_state.set_state(NPCTacticalState.BRACED_PIKES)
	set_state(NPCEnums.State.HOLDING_POSITION)


func _semantic_has_arrived() -> bool:
	return _has_arrived_at(_target_position)


func _is_within_horizontal_distance(destination: Vector3, distance: float) -> bool:
	return _horizontal_distance_to(destination) <= distance


func _configure_navigation_agent() -> void:
	if _navigation_agent == null:
		_use_navigation_agent = false
		_log("Falha de navegacao: NavigationAgent3D ausente. Movimento direto sera usado.")
		return

	if not _tree_has_navigation_region():
		_use_navigation_agent = false
		_log("Falha de navegacao: NavigationRegion3D nao encontrado. Movimento direto sera usado.")
		return

	_navigation_agent.path_desired_distance = arrival_distance
	_navigation_agent.target_desired_distance = arrival_distance
	_navigation_agent.max_speed = movement_speed
	_use_navigation_agent = true


func _process_move_to_position(delta: float) -> void:
	if _has_arrived_at(_target_position):
		_arrive_at_destination()
		return

	var next_position := _get_next_movement_position()
	_move_toward_position(next_position, delta)


func _process_following(delta: float) -> void:
	if current_order == null or not is_instance_valid(current_order.target_node):
		_log("Falha de navegacao: alvo de follow invalido durante execucao.")
		clear_order()
		set_state(NPCEnums.State.BLOCKED)
		return

	var target_node := current_order.target_node
	var target_position := target_node.global_position
	var distance := _horizontal_distance_to(target_position)
	if distance <= follow_distance:
		velocity.x = 0.0
		velocity.z = 0.0
		_apply_gravity(delta)
		move_and_slide()
		return

	var direction := global_position.direction_to(target_position)
	_target_position = target_position - direction * follow_distance
	if _use_navigation_agent:
		_navigation_agent.target_position = _target_position

	_move_toward_position(_get_next_movement_position(), delta)


func _get_next_movement_position() -> Vector3:
	if _use_navigation_agent:
		return _navigation_agent.get_next_path_position()

	return _target_position


func _move_toward_position(destination: Vector3, delta: float) -> void:
	if tactical_state.blocks_auto_movement:
		velocity.x = 0.0
		velocity.z = 0.0
		_apply_gravity(delta)
		move_and_slide()
		return

	var direction := global_position.direction_to(destination)
	direction.y = 0.0

	if direction.length() <= 0.001:
		velocity.x = 0.0
		velocity.z = 0.0
	else:
		direction = direction.normalized()
		var effective_speed := movement_speed * tactical_state.speed_multiplier
		velocity.x = direction.x * effective_speed
		velocity.z = direction.z * effective_speed

	_apply_gravity(delta)
	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0.0
	else:
		var gravity := float(ProjectSettings.get_setting("physics/3d/default_gravity"))
		velocity.y -= gravity * delta


func _has_arrived_at(destination: Vector3) -> bool:
	if _horizontal_distance_to(destination) <= arrival_distance:
		return true

	return _use_navigation_agent and _navigation_agent.is_navigation_finished()


func _arrive_at_destination() -> void:
	velocity = Vector3.ZERO
	_log("Chegada ao destino: %s em %s." % [npc_name, str(global_position)])
	if _semantic_motion_active:
		return
	clear_order()
	set_state(NPCEnums.State.SELECTED if selected else NPCEnums.State.IDLE)


func _process_idle_wander(delta: float) -> void:
	if not idle_wander_enabled or selected or current_order != null or tactical_state.blocks_auto_movement:
		_reset_idle_wander_if_busy()
		return

	if _idle_has_target:
		if _horizontal_distance_to(_idle_target) <= idle_wander_arrival_distance:
			velocity.x = 0.0
			velocity.z = 0.0
			_apply_gravity(delta)
			move_and_slide()
			_idle_has_target = false
			_idle_wait_elapsed = 0.0
			_idle_wait_duration = _next_idle_wait()
			return
		_move_toward_position(_idle_target, delta)
		return

	velocity.x = 0.0
	velocity.z = 0.0
	_apply_gravity(delta)
	move_and_slide()
	_idle_wait_elapsed += delta
	if _idle_wait_elapsed >= _idle_wait_duration:
		_choose_idle_target()


func _choose_idle_target() -> void:
	if idle_wander_radius <= 0.05:
		return
	var angle := randf() * TAU
	var distance := randf_range(idle_wander_radius * 0.35, idle_wander_radius)
	_idle_target = _idle_anchor + Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)
	_idle_has_target = true


func _next_idle_wait() -> float:
	var min_wait := maxf(0.5, idle_wander_interval_min)
	var max_wait := maxf(min_wait, idle_wander_interval_max)
	return randf_range(min_wait, max_wait)


func _reset_idle_wander_if_busy() -> void:
	_idle_has_target = false
	_idle_wait_elapsed = 0.0


func _horizontal_distance_to(destination: Vector3) -> float:
	var from := Vector2(global_position.x, global_position.z)
	var to := Vector2(destination.x, destination.z)
	return from.distance_to(to)


func _update_selection_visual() -> void:
	if _selection_indicator != null:
		_selection_indicator.visible = selected


func _update_name_label() -> void:
	if _name_label != null:
		_name_label.text = npc_name


## Retorna o inventário do NPC para coleta/depósito de recursos.
## Compatível com ResourcePickup._find_actor_inventory() e WarehouseInteractable._find_actor_inventory().
func get_inventory() -> InventoryContainer:
	return _npc_inventory


## Cria o NpcInventory como filho se ainda não existir.
## Chamado em _ready(); garante que cada NPCBase tenha inventário próprio.
func _setup_npc_inventory() -> void:
	var existing := get_node_or_null("NpcInventory")
	if existing is NpcInventory:
		_npc_inventory = existing
		return
	_npc_inventory = NpcInventory.new()
	_npc_inventory.name = "NpcInventory"
	add_child(_npc_inventory)


func _log_movement_fallback_once() -> void:
	if _logged_movement_fallback:
		return

	_logged_movement_fallback = true
	_log("Fallback de movimento direto ativo. NavigationRegion3D funcional nao foi assumido para esta wave.")


func _tree_has_navigation_region() -> bool:
	var root := get_tree().current_scene
	if root == null:
		root = get_tree().root

	return _node_has_navigation_region(root)


func _node_has_navigation_region(node: Node) -> bool:
	if node is NavigationRegion3D:
		return true

	for child in node.get_children():
		if _node_has_navigation_region(child):
			return true

	return false


func _log_order(message: String, order: NPCOrder = null) -> void:
	if not debug_enabled:
		return
	var suffix := ""
	if order != null:
		suffix = " target=%s node=%s reason=%s" % [
			str(order.target_position),
			str(order.target_node.name) if is_instance_valid(order.target_node) else "none",
			order.failure_reason,
		]
	print("[Order] %s %s%s" % [npc_name, message, suffix])


func _log(message: String) -> void:
	if debug_enabled:
		print("[NPC] %s" % message)
