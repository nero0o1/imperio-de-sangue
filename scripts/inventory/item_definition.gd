class_name ItemDefinition
extends Resource

@export var id: StringName
@export var display_name: String = ""
@export var category: StringName = &"resource"
@export var max_stack: int = 99
@export var is_resource: bool = true

func _init(
    p_id: StringName = &"",
    p_display_name: String = "",
    p_category: StringName = &"resource",
    p_max_stack: int = 99,
    p_is_resource: bool = true
) -> void:
    id = p_id
    display_name = p_display_name
    category = p_category
    max_stack = max(1, p_max_stack)
    is_resource = p_is_resource

func is_valid_definition() -> bool:
    return String(id) != "" and max_stack > 0
