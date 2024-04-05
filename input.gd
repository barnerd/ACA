extends ScrollContainer

@onready var tile_map = $Control/HBoxContainer/PanelContainer/MapImages

@export var drag_pressed_duration_threshold: int = 150

signal tilemap_location_clicked(coords: Vector2i, button: MouseButton)

var time_left_mouse_pressed: int
var is_dragging: bool


func _init() -> void:
	is_dragging = false


func _input(_event):
	if _event is InputEventMouseMotion:
		if is_dragging and (Time.get_ticks_msec() - time_left_mouse_pressed) > drag_pressed_duration_threshold:
			#print("drag delta: " + str(_event.relative))
			
			# move scroll bars here
			self.scroll_horizontal -= _event.relative.x
			self.scroll_vertical -= _event.relative.y
	elif _event is InputEventMouseButton:
		if _event.button_index == MOUSE_BUTTON_LEFT and _event.pressed:
			is_dragging = true
			time_left_mouse_pressed = Time.get_ticks_msec()
		if _event.button_index == MOUSE_BUTTON_LEFT and not _event.pressed:
			if (Time.get_ticks_msec() - time_left_mouse_pressed) < drag_pressed_duration_threshold:
				var mouse_position_plus_scroll: Vector2i = Vector2i(_event.position.x + self.scroll_horizontal, _event.position.y + self.scroll_vertical)
				var clicked_cell = tile_map.local_to_map(mouse_position_plus_scroll)
				#print("left: " + str(clicked_cell))
				# coords were left clicked
				tilemap_location_clicked.emit(clicked_cell, MOUSE_BUTTON_LEFT)
			is_dragging = false
		elif _event.button_index == MOUSE_BUTTON_RIGHT and not _event.pressed:
			var mouse_position_plus_scroll: Vector2i = Vector2i(_event.position.x + self.scroll_horizontal, _event.position.y + self.scroll_vertical)
			var clicked_cell = tile_map.local_to_map(mouse_position_plus_scroll)
			#print("right: " + str(clicked_cell))
			# coords were right clicked
			tilemap_location_clicked.emit(clicked_cell, MOUSE_BUTTON_RIGHT)
