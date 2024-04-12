extends VBoxContainer

var zoom_max: int = 30
var zoom_min: int = 1
var zoom_current: int = 15

@onready var map_to_zoom = $"../../ScrollContainer/Control"
@onready var map_to_scale = $"../../ScrollContainer/Control/HBoxContainer/PanelContainer"
@onready var zoom_text = $"Zoom Number"

signal on_map_zoom(zoom_factor: float)


func _init() -> void:
	SignalBus.register_signal("on_map_zoom", on_map_zoom)


func _on_zoom_plus_pressed() -> void:
	zoom_to(zoom_current + 1)


func _on_zoom_minus_pressed() -> void:
	zoom_to(zoom_current - 1)


func _on_zoom_number_text_submitted(new_text: String) -> void:
	# check that submitted text is number
	if new_text.is_valid_int():
		zoom_to(int(new_text))


func zoom_to(_zoom_desired: int = 15):
	zoom_current = clamp(_zoom_desired, zoom_min, zoom_max)
	zoom_text.text = str(zoom_current)

	map_to_zoom.custom_minimum_size = 8400 * Vector2.ONE * zoom_current/10.0
	map_to_scale.scale = Vector2.ONE * zoom_current/10.0
	
	on_map_zoom.emit(zoom_current/10.0)
