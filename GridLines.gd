extends Node2D

@onready var tilemap_cell_size = AgoniaData.MapData.TILE_SIZE
@export var color = Color(1.0, 0.0, 0.0)


func _ready():
	set_process(true)
	SignalBus.connect_to_signal("show_grid_layer_toggled", show_layer)


func _process(_delta):
	queue_redraw()


func _draw():
	for y in range(0, AgoniaData.MapData.MAP_SIZE.y):
		draw_line(Vector2(0, y * tilemap_cell_size.y), Vector2(AgoniaData.MapData.MAP_SIZE.x * tilemap_cell_size.x, y * tilemap_cell_size.y), color)
	
	for x in range(0, AgoniaData.MapData.MAP_SIZE.x):
		draw_line(Vector2(x * tilemap_cell_size.x, 0), Vector2(x * tilemap_cell_size.x, AgoniaData.MapData.MAP_SIZE.y * tilemap_cell_size.y), color)


func show_layer(_on: bool) -> void:
	if _on:
		self.show()
	else:
		self.hide()
