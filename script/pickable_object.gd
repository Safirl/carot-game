class_name PickableObject extends RigidBody3D

func setFreeze(bfreeze: bool):
	freeze = bfreeze
	pass

func highlight(bhighlight):
	if bhighlight:
		$Sprite3D.modulate = Color(1, 0, 0, 1)
	else:
		$Sprite3D.modulate = Color(1, 1, 1, 1)

func throw(impulse: Vector3):
	apply_central_impulse(impulse)
