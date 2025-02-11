extends ScrollContainer

@export var is_horizontal_scroll: bool = false

var labels

@onready var container = $Control
@onready var hlabels = $Control/hLabels
@onready var vlabels = $Control/vLabels
@onready var empty_square = get_node("/root/MapViewer/PanelContainer/VBoxContainer/MarginContainer")


func _ready() -> void:
	SignalBus.connect_to_signal("on_UI_map_h_scrolled", on_UI_map_h_scrolled)
	SignalBus.connect_to_signal("on_UI_map_v_scrolled", on_UI_map_v_scrolled)
	SignalBus.connect_to_signal("on_map_zoom", on_map_zoom)
	
	if is_horizontal_scroll:
		container.custom_minimum_size = Vector2(9600, 24)
		self.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
		self.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		self.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		labels = hlabels
		hlabels.visible = true
		vlabels.visible = false
	else:
		container.custom_minimum_size = Vector2(24, 9600)
		self.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		self.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
		self.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		container.size_flags_horizontal = Control.SIZE_FILL
		labels = vlabels
		hlabels.visible = false
		vlabels.visible = true


func on_UI_map_h_scrolled(_value: int) -> void:
	if is_horizontal_scroll:
		scroll_horizontal = _value


func on_UI_map_v_scrolled(_value: int) -> void:
	if not is_horizontal_scroll:
		scroll_vertical = _value


func on_map_zoom(_factor: float, _old_factor: float) -> void:
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
