extends Control

@onready var credits_window: PackedScene = preload("res://MainScenes/Credits/credits_window.tscn")


func _on_settings_button_pressed() -> void:
	add_child(credits_window.instantiate())
