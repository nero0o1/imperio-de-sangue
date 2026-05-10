class_name PopulationManager
extends Node

signal population_changed(current_population: int, max_capacity: int)

@export var base_capacity: int = 3
@export var capacity_per_house: int = 5
@export var starting_population: int = 0

var population_current: int = 0
var capacity_max: int = 0
var houses_built: int = 0

var _registered_houses: Dictionary = {}


func _ready() -> void:
	add_to_group("population_manager")
	capacity_max = maxi(0, base_capacity)
	population_current = clampi(starting_population, 0, capacity_max)
	population_changed.emit(population_current, capacity_max)


func register_house(house: Node, capacity_bonus: int = -1) -> bool:
	if house == null or not is_instance_valid(house):
		return false

	var key := house.get_instance_id()
	if _registered_houses.has(key):
		return false

	var bonus := capacity_per_house if capacity_bonus < 0 else capacity_bonus
	bonus = maxi(0, bonus)
	_registered_houses[key] = {
		"house": house,
		"capacity": bonus,
	}
	houses_built = _registered_houses.size()
	capacity_max += bonus
	population_changed.emit(population_current, capacity_max)
	print("[Population] Casa registrada: %s. Populacao %d/%d." % [str(house.name), population_current, capacity_max])
	return true


func can_spawn(amount: int = 1) -> bool:
	return amount > 0 and population_current + amount <= capacity_max


func try_reserve_population(amount: int = 1) -> bool:
	if not can_spawn(amount):
		print("[Population] Criacao bloqueada: limite populacional %d/%d." % [population_current, capacity_max])
		return false

	population_current += amount
	population_changed.emit(population_current, capacity_max)
	return true


func release_population(amount: int = 1) -> void:
	if amount <= 0:
		return

	population_current = maxi(0, population_current - amount)
	population_changed.emit(population_current, capacity_max)


func get_status_text() -> String:
	return "Populacao: %d / %d" % [population_current, capacity_max]
