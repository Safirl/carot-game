class_name base_button extends RigidBody3D

#You must have an animation_component with methods : play_interacted_animation and play_activated_animation to use this component.
#This component is used to trigger events and animations.

@onready var animation_component = get_node("AnimationButtonComponent")

var isActivated = false
signal on_button_activated
@export var activation_threshold: int
var interaction_number = 0

func _on_body_entered(body: Node) -> void:
	if body.has_node("PickableObjectComponent"):
		activate()

func activate():
	if isActivated:
		return
	interaction_number += 1
	if interaction_number >= activation_threshold:
		on_button_activated.emit()
		animation_component.play_activated_animation()
		isActivated = true
	else:
		animation_component.play_interacted_animation()

func highlight(bhighlight):
	if bhighlight:
		$Sprite3D.modulate = Color(1, 0, 0, 1)
	else:
		$Sprite3D.modulate = Color(1, 1, 1, 1)

func setFreeze(bfreeze: bool):
	print("highlight")
