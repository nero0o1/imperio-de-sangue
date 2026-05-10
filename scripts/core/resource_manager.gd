extends Node

signal wood_changed(new_value: int)

var wood: int = 0


func reset() -> void:
	wood = 0
	wood_changed.emit(wood)
	print("[Resource] Madeira resetada. Total atual: %d" % wood)


func add_wood(amount: int) -> void:
	if amount <= 0:
		push_warning("[Resource] add_wood(%d) ignorado. O valor deve ser maior que zero." % amount)
		return

	wood += amount
	wood_changed.emit(wood)
	print("[Resource] add_wood(%d) aplicado. Novo total: %d" % [amount, wood])


func can_afford_wood(amount: int) -> bool:
	if amount <= 0:
		return false

	return wood >= amount


func can_spend_wood(amount: int) -> bool:
	return can_afford_wood(amount)


func spend_wood(amount: int) -> bool:
	if amount <= 0:
		push_warning("[Resource] spend_wood(%d) ignorado. O valor deve ser maior que zero." % amount)
		return false

	if not can_afford_wood(amount):
		print("[Resource] spend_wood(%d) falhou. Total atual: %d" % [amount, wood])
		return false

	wood = maxi(wood - amount, 0)
	wood_changed.emit(wood)
	print("[Resource] spend_wood(%d) aplicado. Novo total: %d" % [amount, wood])
	return true


func get_wood() -> int:
	return wood
