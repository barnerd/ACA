class_name ScollInput extends ScrollContainer

@onready var tile_map = AgoniaData.MapData.tile_map_display

@export var drag_pressed_duration_threshold: int = 150

signal tilemap_location_clicked(coords: Vector3i, button: MouseButton)
signal on_UI_map_h_scrolled(destination: int)
signal on_UI_map_v_scrolled(destination: int)

var time_left_mouse_pressed: int
var is_dragging: bool
var current_map_zoom: float = 1.0


func _init() -> void:
	is_dragging = false
	SignalBus.register_signal("tilemap_location_clicked", tilemap_location_clicked)
	SignalBus.register_signal("on_UI_map_h_scrolled", on_UI_map_h_scrolled)
	SignalBus.register_signal("on_UI_map_v_scrolled", on_UI_map_v_scrolled)
	
	get_h_scroll_bar().value_changed.connect(on_UI_map_h_scroll)
	get_v_scroll_bar().value_changed.connect(on_UI_map_v_scroll)


func _ready() -> void:
	SignalBus.connect_to_signal("on_map_zoom", on_map_zoom)
	SignalBus.connect_to_signal("tilemap_location_clicked", on_tilemap_location_clicked)
	
	get_v_scroll_bar().custom_minimum_size.x = 14
	get_h_scroll_bar().custom_minimum_size.y = 14


# attempt to capture mouse scroll wheel
#func _gui_input(event:InputEvent) -> void:
	#if event.is_action_pressed("zoom_in"):
		#return
	#if event.is_action_pressed("zoom_out"):
		#return
#
#
#func _input(event):
	#if event.is_action_pressed("zoom_in"):
		#return
	#if event.is_action_pressed("zoom_out"):
		#return


func _unhandled_input(_event):
	if _event is InputEventMouseMotion:
		if is_dragging and (Time.get_ticks_msec() - time_left_mouse_pressed) > drag_pressed_duration_threshold:
			#print("drag delta: " + str(_event.relative))
			
			# move scroll bars here
			scroll_horizontal -= _event.relative.x
			scroll_vertical -= _event.relative.y
	elif _event is InputEventMouseButton:
		if _event.button_index == MOUSE_BUTTON_LEFT and _event.pressed:
			is_dragging = true
			time_left_mouse_pressed = Time.get_ticks_msec()
		if _event.button_index == MOUSE_BUTTON_LEFT and not _event.pressed:
			if (Time.get_ticks_msec() - time_left_mouse_pressed) < drag_pressed_duration_threshold:
				var clicked_cell = _calc_mouse_on_tilemap(_event.position)
				print("left click: %v" % clicked_cell)
				# coords were left clicked
				tilemap_location_clicked.emit(clicked_cell, MOUSE_BUTTON_LEFT)
			is_dragging = false
		elif _event.button_index == MOUSE_BUTTON_RIGHT and not _event.pressed:
			var clicked_cell = _calc_mouse_on_tilemap(_event.position)
			print("right click: %v" % clicked_cell)
			# coords were right clicked
			tilemap_location_clicked.emit(clicked_cell, MOUSE_BUTTON_RIGHT)


func _calc_mouse_on_tilemap(_mouse: Vector2i) -> Vector3i:
	var mouse_position_plus_scroll: Vector2 = (_mouse as Vector2 - AgoniaData.MapData.TILE_SIZE * current_map_zoom) + Vector2(scroll_horizontal, scroll_vertical)
	mouse_position_plus_scroll /= current_map_zoom
	var clicked_cell_2d = tile_map.local_to_map(mouse_position_plus_scroll)
	var clicked_cell = Vector3i(clicked_cell_2d.x, clicked_cell_2d.y, 0)
	
	return clicked_cell


func on_map_zoom(_factor: float):
	current_map_zoom = _factor


func on_UI_map_h_scroll(_value: float):
	on_UI_map_h_scrolled.emit(scroll_horizontal)


func on_UI_map_v_scroll(_value: float):
	on_UI_map_v_scrolled.emit(scroll_vertical)


func on_tilemap_location_clicked(_coords: Vector3i, _button: MouseButton):
	if _button == MOUSE_BUTTON_LEFT:
		var percent: Vector2 = Vector2(_coords.x / float(AgoniaData.MapData.MAP_SIZE.x), _coords.y / float(AgoniaData.MapData.MAP_SIZE.y))
		var viewport: Vector2 = size
		# TODO: Get the viewport size and add that in
		scroll_horizontal = round(get_h_scroll_bar().max_value * percent.x - viewport.x / 2)
		scroll_vertical = round(get_v_scroll_bar().max_value * percent.y - viewport.y / 2)
