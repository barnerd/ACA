extends Node2D

@onready var vport = $SubViewportContainer/SubViewport


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_T:
			vport.get_texture().get_image().save_png("res://images/numbers-sprite.png")
