class_name TerrainColors extends Sprite2D

# TODO: make images 80 x 80 tiles at 24x24
var display_image: Image


func _init() -> void:
	display_image = self.texture.get_image()


func _ready() -> void:
	SignalBus.connect_to_signal("tile_updated", on_tile_updated)
	SignalBus.connect_to_signal("update_completed", on_update_completed)
	SignalBus.connect_to_signal("save_game_requested", on_save_game_requested)
	
	#reset_image()


func reset_image() -> void:
	display_image = self.texture.get_image()
	
	var image_size = Vector2i(AgoniaData.MapData.MAP_SIZE.x * AgoniaData.MapData.TILE_SIZE.x, AgoniaData.MapData.MAP_SIZE.y * AgoniaData.MapData.TILE_SIZE.y)
	display_image.resize(image_size.x, image_size.y, Image.INTERPOLATE_NEAREST)
	display_image.fill_rect(Rect2i(0, 0, image_size.x, image_size.y), Color.BLACK) #AgoniaData.MapData.terrains_by_id[14].terrain_color_custom)
	
	print ("resetting image")
	for loc in AgoniaData.MapData.map_tiles:
		on_tile_updated(loc)
	
	on_update_completed()


func on_tile_updated(_location: Vector3i) -> void:
	var terrain_id: int = AgoniaData.MapData.map_tiles[_location].terrain_id
	if terrain_id == -1 || terrain_id == 14:
		return
	var color: Color = AgoniaData.MapData.terrains_by_id[terrain_id].terrain_color_custom
	paint_tile(Vector2i(_location.x, _location.y), color)


func on_update_completed() -> void:
	var new_texture = ImageTexture.create_from_image(display_image)
	self.texture = new_texture


func on_save_game_requested() -> void:
	display_image.save_png("res://Flat Files/terrain_colors.png")


func paint_tile(_position: Vector2i, _color: Color) -> void:
	var tile: Rect2i = Rect2i(_position.x * AgoniaData.MapData.TILE_SIZE.x, _position.y * AgoniaData.MapData.TILE_SIZE.y, AgoniaData.MapData.TILE_SIZE.x, AgoniaData.MapData.TILE_SIZE.y)
	
	display_image.fill_rect(tile, _color)


func print_log_image_details(_coords, _mouse):
	print(display_image)
	print(display_image.get_size())
	print(display_image.get_format())
	print(self.texture.resource_name)
	print(self.texture.resource_path)
