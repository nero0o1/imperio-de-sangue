class_name NPCOrder
extends RefCounted

var order_type: int = NPCEnums.OrderType.NONE
var target_position: Vector3 = Vector3.ZERO
var secondary_target_position: Vector3 = Vector3(INF, INF, INF)
var target_node: Node3D = null
var issued_by: Node = null
var queue: bool = false
var priority: int = 0
var status: int = NPCEnums.OrderStatus.PENDING
var failure_reason: String = ""
var debug_label: String = ""
var resource_id_filter: StringName = &""  # GATHER_RESOURCE: se preenchido, só coleta este tipo
var created_at: float = 0.0
var started_at: float = 0.0
var completed_at: float = 0.0


func _init(
	p_order_type: int = NPCEnums.OrderType.NONE,
	p_target_position: Vector3 = Vector3.ZERO,
	p_target_node: Node3D = null,
	p_issued_by: Node = null,
	p_queue: bool = false,
	p_priority: int = 0,
	p_debug_label: String = "",
	p_resource_id_filter: StringName = &""
) -> void:
	order_type = p_order_type
	target_position = p_target_position
	target_node = p_target_node
	issued_by = p_issued_by
	queue = p_queue
	priority = p_priority
	debug_label = p_debug_label
	resource_id_filter = p_resource_id_filter
	created_at = Time.get_unix_time_from_system()


func is_valid() -> bool:
	match order_type:
		NPCEnums.OrderType.MOVE_TO_POSITION:
			return target_position.is_finite()
		NPCEnums.OrderType.ATTACK_MOVE:
			return target_position.is_finite()
		NPCEnums.OrderType.FOLLOW_TARGET, NPCEnums.OrderType.FOLLOW_PLAYER:
			return is_instance_valid(target_node)
		NPCEnums.OrderType.ASSIST_BUILD:
			return true
		NPCEnums.OrderType.STOP, NPCEnums.OrderType.HOLD_POSITION, NPCEnums.OrderType.CLEAR_QUEUE:
			return true
		NPCEnums.OrderType.PATROL:
			return target_position.is_finite()
		NPCEnums.OrderType.FIRE_AT_WILL, NPCEnums.OrderType.HOLD_FIRE, NPCEnums.OrderType.FORM_SHIELD_WALL, NPCEnums.OrderType.BRACE_PIKES:
			return true
		_:
			return order_type != NPCEnums.OrderType.NONE


func get_debug_summary() -> String:
	return "%s status=%s target_position=%s secondary_target_position=%s target_node=%s queue=%s priority=%d issued_by=%s reason=%s label=%s resource_id_filter=%s created_at=%.2f" % [
		NPCEnums.order_type_to_string(order_type),
		NPCEnums.order_status_to_string(status),
		str(target_position),
		str(secondary_target_position),
		str(target_node.name) if is_instance_valid(target_node) else "none",
		str(queue),
		priority,
		str(issued_by.name) if is_instance_valid(issued_by) else "none",
		failure_reason,
		debug_label,
		String(resource_id_filter),
		created_at,
	]


func mark_started() -> void:
	status = NPCEnums.OrderStatus.RUNNING
	started_at = Time.get_unix_time_from_system()


func mark_finished(new_status: int, reason: String = "") -> void:
	status = new_status
	failure_reason = reason
	completed_at = Time.get_unix_time_from_system()


static func make(p_order_type: int, p_position: Vector3 = Vector3.ZERO, target: Node3D = null, actor: Node = null, queued: bool = false, order_priority: int = 0, label: String = "", resource_id: StringName = &"") -> NPCOrder:
	return NPCOrder.new(p_order_type, p_position, target, actor, queued, order_priority, label, resource_id)


static func move_to_position(destination: Vector3, actor: Node = null, queued: bool = false) -> NPCOrder:
	return NPCOrder.new(NPCEnums.OrderType.MOVE_TO_POSITION, destination, null, actor, queued)


static func follow_target(target: Node3D, actor: Node = null, queued: bool = false) -> NPCOrder:
	return NPCOrder.new(NPCEnums.OrderType.FOLLOW_TARGET, Vector3.ZERO, target, actor, queued)


static func follow_player(target: Node3D, actor: Node = null, queued: bool = false) -> NPCOrder:
	return NPCOrder.new(NPCEnums.OrderType.FOLLOW_TARGET, Vector3.ZERO, target, actor, queued, 0, "legacy_follow_player")


static func assist_build(target: Node3D, actor: Node = null, queued: bool = false) -> NPCOrder:
	return NPCOrder.new(NPCEnums.OrderType.ASSIST_BUILD, Vector3.ZERO, target, actor, queued)


static func gather_resource(resource_id: StringName = &"", target: Node3D = null, actor: Node = null, queued: bool = false) -> NPCOrder:
	var order := NPCOrder.new(
		NPCEnums.OrderType.GATHER_RESOURCE,
		Vector3.ZERO,
		target,
		actor,
		queued,
		0,
		"gather_%s" % String(resource_id),
		resource_id
	)
	return order


static func patrol_between(point_a: Vector3, point_b: Vector3, actor: Node = null, queued: bool = false) -> NPCOrder:
	var order := NPCOrder.new(NPCEnums.OrderType.PATROL, point_a, null, actor, queued)
	order.secondary_target_position = point_b
	return order


static func stop(actor: Node = null) -> NPCOrder:
	return NPCOrder.new(NPCEnums.OrderType.STOP, Vector3.ZERO, null, actor)


static func hold_position(actor: Node = null) -> NPCOrder:
	return NPCOrder.new(NPCEnums.OrderType.HOLD_POSITION, Vector3.ZERO, null, actor)


static func clear_queue(actor: Node = null) -> NPCOrder:
	return NPCOrder.new(NPCEnums.OrderType.CLEAR_QUEUE, Vector3.ZERO, null, actor)
