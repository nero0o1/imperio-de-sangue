class_name NpcInventory
extends InventoryContainer

@export var carried_tool_id: StringName = &""
@export var default_npc_capacity: int = 20

func _ready() -> void:
    if capacity_limit < 0:
        capacity_limit = default_npc_capacity

func set_carried_tool(tool_id: StringName) -> void:
    carried_tool_id = tool_id

func has_carried_tool() -> bool:
    return String(carried_tool_id) != ""
