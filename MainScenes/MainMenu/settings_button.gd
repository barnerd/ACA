extends Control

@onready var settings_window: PackedScene = preload("res://MainScenes/Settings/settings_window.tscn")


func _on_settings_button_pressed() -> void:
	add_child(settings_window.instantiate())
