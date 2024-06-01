extends Node2D

@onready var viewport = $SubViewportContainer/Subviewport


func _ready() -> void:
	#await RenderingServer.frame_post_draw
	pass



func _input(event) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_S:
			if event.meta_pressed:
				print("Cmd-S for snapshot was pressed")
				var image_to_save = viewport.get_texture().get_image()
				image_to_save.save_png("res://Flat Files/agonia_map.png")

