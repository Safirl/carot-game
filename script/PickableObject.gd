class_name PickableObject extends StaticBody3D

@export var weight = 0
@export var isPicked: bool:
	set(newIsPicked):
		isPicked = newIsPicked
		_setLocation()
	
func highlight(bhighlight: bool):
	if bhighlight:
		$Sprite3D.modulate = Color(1, 0, 0, 1)
	else:
		$Sprite3D.modulate = Color(1, 1, 1, 1)
		
func _setLocation():
	var player = owner.find_child("Player")
	if !player:
		return
	get_parent().remove_child(self)
	player.add_child(self)
