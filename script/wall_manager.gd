extends Node3D

@onready var walls: Array[Sprite3D]

func _ready() -> void:
	for child in get_children():
		var sprite: Sprite3D = child
		if sprite:
			
