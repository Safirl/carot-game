extends Area3D

@export var life: int = 1

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
	if body.name == "Player":
		body.hit()
	
