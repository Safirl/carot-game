extends Node3D

func play_interacted_animation():
	print("verriere interaction")

func play_activated_animation():
	print("verriere activated")
	call_deferred("_deffered_disable_door")
	
func _deffered_disable_door():
	var door: CollisionShape3D = owner.get_node("Door").get_node("Door")
	door.disabled = true
	get_parent().queue_free()
