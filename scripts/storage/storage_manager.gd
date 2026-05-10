class_name StorageManager
extends Node

var _warehouses: Dictionary = {}

func register_warehouse(warehouse: Warehouse) -> void:
    if warehouse == null:
        push_warning("Tentativa de registrar armazém nulo.")
        return

    _warehouses[warehouse.warehouse_id] = warehouse

func unregister_warehouse(warehouse_id: StringName) -> void:
    _warehouses.erase(warehouse_id)

func get_warehouse(warehouse_id: StringName) -> Warehouse:
    return _warehouses.get(warehouse_id, null)

func get_warehouses_by_settlement(settlement_id: StringName) -> Array[Warehouse]:
    var result: Array[Warehouse] = []

    for warehouse in _warehouses.values():
        if warehouse != null and warehouse.settlement_id == settlement_id:
            result.append(warehouse)

    return result

func get_total_available(settlement_id: StringName, item_id: StringName) -> int:
    var total: int = 0

    for warehouse in get_warehouses_by_settlement(settlement_id):
        total += warehouse.get_available(item_id)

    return total

func can_pay_from_settlement(settlement_id: StringName, costs: Dictionary) -> bool:
    for item_id in costs.keys():
        var required: int = int(costs[item_id])
        if required < 0:
            return false
        if get_total_available(settlement_id, item_id) < required:
            return false

    return true

func pay_from_settlement(settlement_id: StringName, costs: Dictionary) -> bool:
    if not can_pay_from_settlement(settlement_id, costs):
        return false

    for item_id in costs.keys():
        var remaining: int = int(costs[item_id])

        for warehouse in get_warehouses_by_settlement(settlement_id):
            if remaining <= 0:
                break

            var removed: int = warehouse.withdraw(item_id, remaining)
            remaining -= removed

    return true
