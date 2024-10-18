extends Control

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
	pass

func _on_quit_button_pressed() -> void:
	get_tree().quit()
	pass
