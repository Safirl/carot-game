extends Control

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Map.tscn")
	pass
	
func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Credits.tscn")
	pass

func _on_quit_button_pressed() -> void:
	get_tree().quit()
	pass
