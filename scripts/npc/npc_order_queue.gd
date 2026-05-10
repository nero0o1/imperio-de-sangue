class_name NPCOrderQueue
extends RefCounted

var current_order: NPCOrder = null
var pending_orders: Array[NPCOrder] = []


func has_current_order() -> bool:
	return current_order != null


func enqueue(order: NPCOrder) -> void:
	order.status = NPCEnums.OrderStatus.PENDING
	pending_orders.append(order)


func replace_with(order: NPCOrder) -> Array[NPCOrder]:
	var cancelled: Array[NPCOrder] = []
	if current_order != null:
		current_order.mark_finished(NPCEnums.OrderStatus.CANCELLED, "Replaced by new non-queued order.")
		cancelled.append(current_order)
	for pending in pending_orders:
		pending.mark_finished(NPCEnums.OrderStatus.CANCELLED, "Cleared by new non-queued order.")
		cancelled.append(pending)
	pending_orders.clear()
	current_order = order
	return cancelled


func clear_pending(reason: String = "Queue cleared.") -> Array[NPCOrder]:
	var cancelled: Array[NPCOrder] = []
	for pending in pending_orders:
		pending.mark_finished(NPCEnums.OrderStatus.CANCELLED, reason)
		cancelled.append(pending)
	pending_orders.clear()
	return cancelled


func cancel_current(reason: String = "Current order cancelled.") -> NPCOrder:
	var cancelled := current_order
	if cancelled != null:
		cancelled.mark_finished(NPCEnums.OrderStatus.CANCELLED, reason)
	current_order = null
	return cancelled


func finish_current(status: int, reason: String = "") -> NPCOrder:
	var finished := current_order
	if finished != null:
		finished.mark_finished(status, reason)
	current_order = null
	return finished


func start_next() -> NPCOrder:
	if pending_orders.is_empty():
		current_order = null
		return null
	current_order = pending_orders.pop_front()
	return current_order
