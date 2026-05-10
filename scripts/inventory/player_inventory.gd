class_name PlayerInventory
extends InventoryContainer

@export var allow_equipment_items: bool = true
@export var allow_resource_items: bool = true

func can_receive_item(_item_id: StringName, quantity: int) -> bool:
    return quantity > 0
