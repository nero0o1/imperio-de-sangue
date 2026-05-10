extends Node

signal game_state_changed(new_state: int)
signal game_won
signal game_lost(reason: String)

enum GameState {
	SETUP,
	EXPLORATION,
	PREPARATION,
	WAVE_ACTIVE,
	VICTORY,
	DEFEAT
}

var current_state: int = GameState.SETUP
var is_game_finished := false


func _ready() -> void:
	start_game()


func start_game() -> void:
	if is_game_finished:
		return

	set_state(GameState.EXPLORATION)


func set_state(new_state: int) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	game_state_changed.emit(current_state)


func win_game() -> void:
	if is_game_finished:
		return

	is_game_finished = true
	set_state(GameState.VICTORY)
	game_won.emit()


func lose_game(reason: String = "") -> void:
	if is_game_finished:
		return

	is_game_finished = true
	set_state(GameState.DEFEAT)
	game_lost.emit(reason)


func reset_session() -> void:
	is_game_finished = false
	set_state(GameState.SETUP)
	start_game()
