extends Area3D

@export var pathToRessource: String
var is_already_playing: bool
var current_audio_stream

func _on_body_entered(body: Node3D) -> void:
	if is_already_playing:
		return
		
	if body.name == "Player":
		is_already_playing = true
		current_audio_stream = AudioStreamManager.add_audio_stream_to_queue(pathToRessource)

func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		is_already_playing = false
		AudioStreamManager.remove_audio_stream(current_audio_stream)
