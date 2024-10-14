extends Node3D

var queued_audio_streams: Array[AudioStreamPlayer]
var audio_streams_to_remove: Array[AudioStreamPlayer]
@export var current_audio_streams: Array[AudioStreamPlayer]
var default_stream_path = "res://Musics/Carrot.mp3"
var DefaultAudioStream: AudioStreamPlayer

func add_audio_stream_to_queue(pathToRes: String) -> AudioStreamPlayer:
	var new_audio_stream = _init_new_audio_stream(pathToRes)
	if !new_audio_stream:
		return null
	queued_audio_streams.append(new_audio_stream)
	return new_audio_stream

func remove_audio_stream(audioStreamToRemove: AudioStreamPlayer):
	if audio_streams_to_remove.find(audioStreamToRemove):
		return
	audio_streams_to_remove.append(audioStreamToRemove)

##Init default audioStream
func _ready() -> void:
	DefaultAudioStream = _init_new_audio_stream(default_stream_path)
	if !DefaultAudioStream:
		return
	DefaultAudioStream.finished.connect(_on_rythmic_audio_stream_finished)
	DefaultAudioStream.play()

##Used to init an audio streal
func _init_new_audio_stream(pathToRes: String) -> AudioStreamPlayer:
	if !ResourceLoader.exists(pathToRes):
		push_error("ressource is not valid!")
		return null
		
	var NewQueuedAudioStream = AudioStreamPlayer.new()
	var audio_stream = ResourceLoader.load(pathToRes) as AudioStreamMP3
	NewQueuedAudioStream.stream = audio_stream
	add_child(NewQueuedAudioStream)
	NewQueuedAudioStream.owner = self
	return NewQueuedAudioStream

##Called when the base audio stream has done a loop. adds new audio streams and plays them.
func _on_rythmic_audio_stream_finished() -> void:
	print("finished")
	for audio_stream in queued_audio_streams:
		if !current_audio_streams.find(audio_stream):
			current_audio_streams.append(audio_stream)
			audio_stream.finished.connect(_on_any_audio_stream_finished)
			audio_stream.play()
	queued_audio_streams.clear()
	DefaultAudioStream.play()

func _on_any_audio_stream_finished() -> void:
	##First we want to delete old streams
	var new_audio_stream_to_remove: Array
	for audio_stream in audio_streams_to_remove:
		if !current_audio_streams.find(audio_stream):
			audio_stream.queue_free()
			continue
		if audio_stream.playing == false:
			current_audio_streams.erase(audio_stream)
			audio_stream.queue_free()
			continue
		new_audio_stream_to_remove.append(audio_stream)
	audio_streams_to_remove = new_audio_stream_to_remove
	
	##Then we want to play the currents that are not already playing
	for audio_stream in audio_streams_to_remove:
		if audio_stream.playing == false:
			audio_stream.play()
