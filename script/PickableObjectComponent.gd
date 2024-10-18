class_name PickableObjectComponent extends Node3D

#Class used to add the possibility to an object to be picked. WARNING :
#This object should be right under the parentTarget and the parent target should implments :
#setFreeze(bool) and highlight(bool).

@export var weight = 0
@onready var ParentTarget = get_parent()
@export var isPicked: bool:
	set(newIsPicked):
		isPicked = newIsPicked
		if newIsPicked:
			_setPickedLocation()
		else:
			_unpick()
			
	
func highlight(bhighlight: bool):
	ParentTarget.highlight(bhighlight)
		
func _setPickedLocation():
	var player = ParentTarget.owner.find_child("Player")
	var parent_sprite
	if !player:
		return
	ParentTarget.owner.remove_child(ParentTarget)
	player.add_child(ParentTarget)
	if ParentTarget.has_node("AnimatedSprite3D"):
		parent_sprite = ParentTarget.get_node("AnimatedSprite3D")
	elif ParentTarget.has_node("Sprite3D"):
		parent_sprite = ParentTarget.get_node("Sprite3D")
	var old_sprite_scale = parent_sprite.scale
	ParentTarget.owner = player
	parent_sprite.scale = old_sprite_scale
	ParentTarget.position = Vector3(0, 1, 0)
	ParentTarget.setFreeze(true)

func _unpick():
	var root = ParentTarget.owner.owner
	var old_global_transform = global_transform
	var old_sprite_scale = scale
	ParentTarget.owner.remove_child(ParentTarget)
	root.add_child(ParentTarget)
	ParentTarget.owner = root
	ParentTarget.transform = Transform3D.IDENTITY
	ParentTarget.global_transform = old_global_transform
	ParentTarget.scale = old_sprite_scale
	ParentTarget.setFreeze(false)
	
