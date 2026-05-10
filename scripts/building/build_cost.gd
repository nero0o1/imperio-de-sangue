class_name BuildCost
extends Resource

@export var building_id: StringName = &""
@export var costs: Dictionary = {}

func set_cost(item_id: StringName, quantity: int) -> void:
    if String(item_id) == "" or quantity < 0:
        return
    costs[item_id] = quantity

func remove_cost(item_id: StringName) -> void:
    costs.erase(item_id)

func get_cost(item_id: StringName) -> int:
    return int(costs.get(item_id, 0))

func is_valid_cost() -> bool:
    for item_id in costs.keys():
        if String(item_id) == "" or int(costs[item_id]) < 0:
            return false
    return true

func duplicate_costs() -> Dictionary:
    return costs.duplicate(true)
