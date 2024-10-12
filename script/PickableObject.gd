class_name PickableObject extends RigidBody3D

@export var weight = 0
@export var isPicked: bool:
	set(newIsPicked):
		isPicked = newIsPicked
		if newIsPicked:
			_setPickedLocation()
		else:
			_unpick()
			
	
func highlight(bhighlight: bool):
	if bhighlight:
		$Sprite3D.modulate = Color(1, 0, 0, 1)
	else:
		$Sprite3D.modulate = Color(1, 1, 1, 1)
		
func _setPickedLocation():
	var player = owner.find_child("Player")
	if !player:
		return
	get_parent().remove_child(self)
	var old_scale = scale
	player.add_child(self)
	transform = Transform3D.IDENTITY
	scale = old_scale
	position = Vector3(0, 1, 0)
	freeze = true

func _unpick():
	var root = get_parent().owner
	var old_global_transform = global_transform
	var old_scale = scale
	get_parent().remove_child(self)
	transform = Transform3D.IDENTITY
	root.add_child(self)
	owner = root
	global_transform = old_global_transform
	scale = old_scale
	freeze = false
	
