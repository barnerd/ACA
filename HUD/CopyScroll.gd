extends ScrollContainer

@export var is_horizontal_scroll: bool = false
var container
var labels
@onready var empty_square = get_node("/root/Node2D/Control/PanelContainer/VBoxContainer/MarginContainer")


func _ready() -> void:
	SignalBus.connect_to_signal("on_UI_map_h_scrolled", on_UI_map_h_scrolled)
	SignalBus.connect_to_signal("on_UI_map_v_scrolled", on_UI_map_v_scrolled)
	SignalBus.connect_to_signal("on_map_zoom", on_map_zoom)
	
	container = get_node("Control")
	labels = get_node("Control/Labels")


func on_UI_map_h_scrolled(_value: int) -> void:
	if is_horizontal_scroll:
		scroll_horizontal = _value


func on_UI_map_v_scrolled(_value: int) -> void:
	if not is_horizontal_scroll:
		scroll_vertical = _value


func on_map_zoom(_factor: float) -> void:
	if _factor < 1.0:
		self.visible = false
		empty_square.visible = false
	else:
		self.visible = true
		empty_square.visible = true
		
		if is_horizontal_scroll:
			container.custom_minimum_size.x = AgoniaData.MapData.MAP_SIZE.x * AgoniaData.MapData.TILE_SIZE.x * _factor
			container.custom_minimum_size.y = AgoniaData.MapData.TILE_SIZE.y * _factor
			labels.scale = Vector2.ONE * _factor
		else:
			container.custom_minimum_size.x = AgoniaData.MapData.TILE_SIZE.x * _factor
			container.custom_minimum_size.y = AgoniaData.MapData.MAP_SIZE.y * AgoniaData.MapData.TILE_SIZE.y * _factor
			empty_square.add_theme_constant_override("margin_left", AgoniaData.MapData.TILE_SIZE.x * _factor)
			labels.scale = Vector2.ONE * _factor
