extends Node

@export var shift_press: AudioStream
@export var key1_press: AudioStream
@export var key2_press: AudioStream
@export var key3_press: AudioStream
@export var ding_sound: AudioStream


func play_sound(_sound: String) -> void:
	match _sound:
		"shift":
			SoundManager.play_sound(shift_press)
		"key1":
			SoundManager.play_sound(key1_press)
		"key2":
			SoundManager.play_sound(key2_press)
		"key3":
			SoundManager.play_sound(key3_press)
		"ding":
			SoundManager.play_sound(ding_sound)
