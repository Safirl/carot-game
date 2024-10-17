extends ShapeCast3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for collision in collision_result:
		if collision.collider.name == "Player":
			collision.collider.hit()
