class_name PickableObject extends Sprite3D

@export var weight = 0
@export var isPicked: bool:
	set(newIsPicked):
		isPicked = newIsPicked
		_setLocation()
	
func highlight(bhighlight: bool):
	if bhighlight:
		modulate = Color(1, 0, 0, 1)
	else:
		modulate = Color(1, 1, 1, 1)
		
func _setLocation():
	var player = owner.find_child("Player")
	if !player:
		return
	get_parent().remove_child(self)
	var old_global_transform = global_transform
	player.add_child(self)
	transform = Transform3D.IDENTITY
