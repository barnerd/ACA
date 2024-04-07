class_name TerrainColors extends Sprite2D

var tile_size: int = 24
@onready var display_sprite: Sprite2D = $"."
var display_image: Image
@export var border_color: Color = Color.BLACK

func _ready() -> void:
	display_image = display_sprite.texture.get_image()
	
	display_image.resize(8400, 8400, Image.INTERPOLATE_NEAREST)
	display_image.fill_rect(Rect2i(0, 0, 8400, 8400), border_color)
	
	SignalBus.connect_to_signal("savefile_loaded", apply_image)


func paint_tile(_position: Vector2i, _color: Color) -> void:
	var rect_size = tile_size - 1
	var tile: Rect2i = Rect2i(_position.x * tile_size, _position.y * tile_size, rect_size, rect_size)
	
	display_image.fill_rect(tile, _color)


func apply_image():
	var new_texture = ImageTexture.create_from_image(display_image)
	display_sprite.texture = new_texture
