class_name ScollInput extends ScrollContainer

@onready var tile_map = MapDetailsSingleton.tile_map_display

@export var drag_pressed_duration_threshold: int = 150

signal tilemap_location_clicked(coords: Vector3i, button: MouseButton)

var time_left_mouse_pressed: int
var is_dragging: bool
var current_map_zoom: float = 1.0


func _init() -> void:
	is_dragging = false
	SignalBus.register_signal("tilemap_location_clicked", tilemap_location_clicked)


func _ready() -> void:
	SignalBus.connect_to_signal("on_map_zoom", on_map_zoom)


func _unhandled_input(_event):
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
				var clicked_cell = _calc_mouse_on_tilemap(_event.position)
				print("left: " + str(clicked_cell))
				# coords were left clicked
				tilemap_location_clicked.emit(clicked_cell, MOUSE_BUTTON_LEFT)
			is_dragging = false
		elif _event.button_index == MOUSE_BUTTON_RIGHT and not _event.pressed:
			var clicked_cell = _calc_mouse_on_tilemap(_event.position)
			print("right: " + str(clicked_cell))
			# coords were right clicked
			tilemap_location_clicked.emit(clicked_cell, MOUSE_BUTTON_RIGHT)


func _calc_mouse_on_tilemap(_mouse: Vector2i) -> Vector3i:
	var mouse_position_plus_scroll: Vector2i = _mouse + Vector2i(scroll_horizontal, scroll_vertical)
	mouse_position_plus_scroll /= current_map_zoom
	var clicked_cell_2d = tile_map.local_to_map(mouse_position_plus_scroll)
	var clicked_cell = Vector3i(clicked_cell_2d.x, clicked_cell_2d.y, 0)
	
	return clicked_cell


func on_map_zoom(_factor: float):
	current_map_zoom = _factor
