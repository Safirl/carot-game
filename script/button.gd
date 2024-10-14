extends RigidBody3D

var isActivated = false
signal on_button_activated

func _on_body_entered(body: Node) -> void:
	if body.get_node("PickableObjectComponent"):
		activate()

func activate():
	$Sprite3D.modulate = Color(1, 0, 0, 1)
	if isActivated:
		return
	emit_signal("on_button_activated")
