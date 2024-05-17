extends HBoxContainer

@export var zoom_max: int = 96
@export var zoom_min: int = 1
var zoom_current: int = 24

@onready var map_to_zoom = $"/root/Node2D/Control/PanelContainer/VBoxContainer/HBoxContainer/ScrollContainer/Control"
@onready var map_to_scale = $"/root/Node2D/Control/PanelContainer/VBoxContainer/HBoxContainer/ScrollContainer/Control/PanelContainer"
@onready var zoom_text = $"Zoom Number"

signal on_map_zoom(zoom_factor: float, old_factor: float)


func _init() -> void:
	SignalBus.register_signal("on_map_zoom", on_map_zoom)


# attempt to capture mouse scroll wheel
#func _gui_input(event:InputEvent) -> void:
	#if event.is_action_pressed("zoom_in"):
		#_on_zoom_plus_pressed()
	#if event.is_action_pressed("zoom_out"):
		#_on_zoom_minus_pressed()
#
#
#func _input(event):
	#if event.is_action_pressed("zoom_in"):
		#_on_zoom_plus_pressed()
	#if event.is_action_pressed("zoom_out"):
		#_on_zoom_minus_pressed()


func _on_zoom_plus_pressed() -> void:
	zoom_to(zoom_current + 1)


func _on_zoom_minus_pressed() -> void:
	zoom_to(zoom_current - 1)


func _on_zoom_number_text_submitted(new_text: String) -> void:
	# check that submitted text is number
	if new_text.is_valid_int():
		zoom_to(int(new_text))


func zoom_to(_zoom_desired: int = 24):
	var old_zoom = zoom_current
	
	zoom_current = clamp(_zoom_desired, zoom_min, zoom_max)
	zoom_text.text = str(zoom_current)
	
	# TODO: move these next two lines to local to those nodes and listen to signal instead
	map_to_zoom.custom_minimum_size = AgoniaData.MapData.MAP_SIZE.x * AgoniaData.MapData.TILE_SIZE.x * Vector2.ONE * zoom_current/24.0
	map_to_scale.scale = Vector2.ONE * zoom_current/24.0
	
	on_map_zoom.emit(zoom_current/24.0, old_zoom/24.0)
