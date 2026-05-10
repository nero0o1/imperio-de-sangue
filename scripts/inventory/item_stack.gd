class_name ItemStack
extends Resource

@export var item_id: StringName
@export var quantity: int = 0

func _init(p_item_id: StringName = &"", p_quantity: int = 0) -> void:
    item_id = p_item_id
    quantity = max(0, p_quantity)

func is_empty() -> bool:
    return String(item_id) == "" or quantity <= 0

func can_merge(other: ItemStack) -> bool:
    if other == null:
        return false
    return item_id == other.item_id

func add_amount(amount: int) -> void:
    if amount <= 0:
        return
    quantity += amount

func remove_amount(amount: int) -> int:
    if amount <= 0:
        return 0

    var removed: int = min(quantity, amount)
    quantity -= removed
    return removed

func duplicate_stack() -> ItemStack:
    return ItemStack.new(item_id, quantity)
