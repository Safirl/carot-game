extends Area3D

@export var life: int = 1
@export var broken_texture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if life > 0:
		$AnimatedSprite3D.play("anim")
	else:
		$AnimatedSprite3D.stop()

func _on_body_entered(body: Node3D) -> void:
	if life < 1:
		return
	if body.has_node("PickableObjectComponent"):
		life -= 1
	if life < 1:
		$Sprite3D.texture = broken_texture
		$FogVolume.queue_free()
		$ShapeCast3D.queue_free()
