class_name TerrainColors extends Sprite2D

var display_image: Image
@export var border_color: Color = Color.BLACK

func _ready() -> void:
	display_image = self.texture.get_image()
	
	var image_size = Vector2i(AgoniaData.MapData.MAP_SIZE.x * AgoniaData.MapData.TILE_SIZE.x, AgoniaData.MapData.MAP_SIZE.y * AgoniaData.MapData.TILE_SIZE.y)
	display_image.resize(image_size.x, image_size.y, Image.INTERPOLATE_NEAREST)
	display_image.fill_rect(Rect2i(0, 0, image_size.x, image_size.y), border_color)
	
	SignalBus.connect_to_signal("savefile_loaded", apply_image)
	SignalBus.connect_to_signal("tilemap_location_clicked", print_log_image_details)


func paint_tile(_position: Vector2i, _color: Color) -> void:
	var tile: Rect2i = Rect2i(_position.x * AgoniaData.MapData.TILE_SIZE.x, _position.y * AgoniaData.MapData.TILE_SIZE.y, AgoniaData.MapData.TILE_SIZE.x, AgoniaData.MapData.TILE_SIZE.y)
	
	display_image.fill_rect(tile, _color)


func apply_image():
	var new_texture = ImageTexture.create_from_image(display_image)
	self.texture = new_texture


func print_log_image_details(_coords, _mouse):
	print(display_image)
	print(display_image.get_size())
	print(display_image.get_format())
	print(self.texture.resource_name)
	print(self.texture.resource_path)

