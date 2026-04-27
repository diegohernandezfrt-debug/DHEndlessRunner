extends Node

@onready var music = $MusicPlayer

@export var land_music: AudioStream
@export var river_music: AudioStream
@export var sky_music: AudioStream

func play_music(stream: AudioStream):
	if music.stream == stream:
		return
	
	music.stop()
	music.stream = stream
	music.play()
