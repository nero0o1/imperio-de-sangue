class_name InventoryContainer
extends Node

@export var capacity_limit: int = -1

var _items: Dictionary = {}

signal item_added(item_id: StringName, quantity: int)
signal item_removed(item_id: StringName, quantity: int)
signal inventory_changed()

func add_item(item_id: StringName, quantity: int) -> int:
    if String(item_id) == "" or quantity <= 0:
        return quantity

    var accepted: int = quantity

    if capacity_limit >= 0:
        var free_space: int = max(0, capacity_limit - get_total_quantity())
        accepted = min(quantity, free_space)

    if accepted <= 0:
        return quantity

    _items[item_id] = get_quantity(item_id) + accepted

    item_added.emit(item_id, accepted)
    inventory_changed.emit()

    return quantity - accepted

func remove_item(item_id: StringName, quantity: int) -> int:
    if String(item_id) == "" or quantity <= 0:
        return 0

    var current: int = get_quantity(item_id)
    var removed: int = min(current, quantity)

    if removed <= 0:
        return 0

    var remaining: int = current - removed
    if remaining <= 0:
        _items.erase(item_id)
    else:
        _items[item_id] = remaining

    item_removed.emit(item_id, removed)
    inventory_changed.emit()

    return removed

func get_quantity(item_id: StringName) -> int:
    return int(_items.get(item_id, 0))

func has_item(item_id: StringName, quantity: int) -> bool:
    if quantity <= 0:
        return true
    return get_quantity(item_id) >= quantity

func has_items(costs: Dictionary) -> bool:
    for item_id in costs.keys():
        var required: int = int(costs[item_id])
        if required < 0:
            return false
        if get_quantity(item_id) < required:
            return false
    return true

func remove_items(costs: Dictionary) -> bool:
    if not has_items(costs):
        return false

    for item_id in costs.keys():
        remove_item(item_id, int(costs[item_id]))

    return true

func add_resource(resource_id: String, amount: int) -> void:
    if resource_id.strip_edges().is_empty() or amount <= 0:
        return

    add_item(StringName(resource_id), amount)

func remove_resource(resource_id: String, amount: int) -> bool:
    if resource_id.strip_edges().is_empty() or amount <= 0:
        return false
    if not has_resource(resource_id, amount):
        return false

    return remove_item(StringName(resource_id), amount) == amount

func get_resource(resource_id: String) -> int:
    if resource_id.strip_edges().is_empty():
        return 0

    return get_quantity(StringName(resource_id))

func has_resource(resource_id: String, amount: int) -> bool:
    if resource_id.strip_edges().is_empty():
        return false
    if amount <= 0:
        return true

    return get_resource(resource_id) >= amount

func get_all_resources() -> Dictionary:
    var snapshot: Dictionary = {}
    for item_id in _items.keys():
        snapshot[String(item_id)] = int(_items[item_id])

    return snapshot

func is_empty() -> bool:
    return _items.is_empty()

func transfer_to(target: InventoryContainer, item_id: StringName, quantity: int) -> int:
    if target == null or String(item_id) == "" or quantity <= 0:
        return 0

    var removed: int = remove_item(item_id, quantity)
    if removed <= 0:
        return 0

    var leftover: int = target.add_item(item_id, removed)
    var transferred: int = removed - leftover

    if leftover > 0:
        add_item(item_id, leftover)

    return transferred

func get_total_quantity() -> int:
    var total: int = 0
    for item_id in _items.keys():
        total += int(_items[item_id])
    return total

func get_all_items() -> Dictionary:
    return _items.duplicate(true)

func clear() -> void:
    _items.clear()
    inventory_changed.emit()
