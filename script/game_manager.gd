extends Node3D

signal game_state_changed(game_state)

var score
var contamination_percent: float = 100
@export var active_objectives: int

func _process(delta: float) -> void:
	contamination_percent -= (.2 * active_objectives) * delta
	if contamination_percent <= 0:
		game_state_changed.emit(true)
