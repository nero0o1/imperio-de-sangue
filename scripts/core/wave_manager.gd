extends Node

signal wave_started(wave_index: int)
signal wave_finished(wave_index: int)

var current_wave := 0
var wave_active := false


func start_wave() -> void:
	if wave_active:
		return

	current_wave += 1
	wave_active = true
	wave_started.emit(current_wave)


func finish_wave_for_debug() -> void:
	if not wave_active:
		return

	wave_active = false
	wave_finished.emit(current_wave)


func reset() -> void:
	current_wave = 0
	wave_active = false
