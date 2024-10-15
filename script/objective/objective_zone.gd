extends Area3D

signal on_valve_state_changed

var opened_percentage = 100.
@export var is_opened: bool = true

func _ready() -> void:
	on_valve_state_changed.emit(is_opened)

func open_valve():
	opened_percentage = 100.
	is_opened = true
	on_valve_state_changed.emit(is_opened)

func close_valve(force: int):
	if !is_opened:
		return
	opened_percentage -= 1 * force
	if opened_percentage <= 0.:
		is_opened = false
	on_valve_state_changed.emit(is_opened)

func highlight(bhighlight):
	$AnimatedSprite3D.modulate = Color(1, 0, 0, 1) if bhighlight else Color(1, 1, 1, 1)
