extends Node2D

var circle_scene = preload("res://UI/circle.tscn")


func _ready() -> void:
	SignalBus.connect_to_signal("new_path_found", on_new_path_found)
	SignalBus.connect_to_signal("clear_path", clear_path)


func on_new_path_found(_path: Array[Vector2i], _cost: int) -> void:
	clear_path()
	draw_path(_path)


func clear_path() -> void:
	# clear old path
	for c in get_children():
		c.queue_free()


func draw_path(_path: Array[Vector2i]) -> void:
	var start_color: Color = Color("14d948cc")
	var path_color: Color = Color("1a1918cc")
	var end_color: Color = Color("fc4103cc")
	var radius: float = AgoniaData.MapData.TILE_SIZE.x / 2.0 * .5
	
	if _path.size() > 0:
		# start
		# _path[0]
		_add_point(_path[0], radius, start_color)
	
	for i in range(1, _path.size() - 1):
		# path minus start & finish
		#_path[i]
		_add_point(_path[i], radius, path_color)
	
	if _path.size() > 1:
		# finish
		# _path[-1]
		_add_point(_path[-1], radius, end_color)


func _add_point(_point: Vector2i, _radius: float, _color: Color) -> void:
	var c = circle_scene.instantiate()
	c.color = _color
	c.radius = _radius
	c.position = Vector2(_point.x * AgoniaData.MapData.TILE_SIZE.x + AgoniaData.MapData.TILE_SIZE.x / 2.0, _point.y * AgoniaData.MapData.TILE_SIZE.y + AgoniaData.MapData.TILE_SIZE.y / 2.0)
	add_child(c)
