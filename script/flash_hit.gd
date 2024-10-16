extends Node3D

var parent_sprite
var flash_duration: float = 0.2
var flash_timer: float = 0.0
var original_scale

func _ready() -> void:
	if get_parent().has_node("Sprite3D"):
		parent_sprite = get_parent().get_node("Sprite3D")
	elif get_parent().has_node("AnimatedSprite3D"):
		parent_sprite = get_parent().get_node("AnimatedSprite3D")
	if parent_sprite:
		original_scale = parent_sprite.scale
	
func _process(delta: float) -> void:
	if flash_timer > 0:
		flash_timer -= delta
		if flash_timer <= 0:
			# Remet la couleur d'origine quand le temps est écoulé
			parent_sprite.modulate = Color(1, 1, 1, 1)
			parent_sprite.scale = original_scale

func start_flash(duration: float):
	flash_duration = duration
	flash_timer = flash_duration
	parent_sprite.modulate = Color(1, 0, 0, 1)
	parent_sprite.scale = original_scale * Vector3(1, 1.2, .8)
