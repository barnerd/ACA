extends Control

const ALPHABET_STRING: String = "abcdefghijklmnopqrstuvwxyz"

# To get a screen shot, run the game at zoom: 24
# line up the Menu with the grid in the upper right
# turn off the grid
# grab a shot from the Menu in the upper right to
# the lower left without include the pathfinder or coords
#
# there might be a better way of just using app ss (is that cmd + shft + 5?)
# on zoom: 24 and centered by clicking on the tile
const BACKGROUND_IMAGES: Array = [
	preload("res://MainScenes/main_menu_background/forsaken_bridge.png"),
	preload("res://MainScenes/main_menu_background/forsaken_cap.png"),
	preload("res://MainScenes/main_menu_background/forsaken_dracos.png"),
	preload("res://MainScenes/main_menu_background/forsaken_north.png"),
	preload("res://MainScenes/main_menu_background/forsaken_snow.png"),
	preload("res://MainScenes/main_menu_background/forsaken_south.png"),
	preload("res://MainScenes/main_menu_background/kyri.png"),
	preload("res://MainScenes/main_menu_background/order_south.png"),
	preload("res://MainScenes/main_menu_background/trailblazer.png"),
	]

@onready var background_texture: TextureRect = $TextureRect
@onready var characters_folder: Control = $Characters
@onready var panel_fader: Panel = $Panel
@onready var wait_timer: Timer = $Timer

@export var fade_time: float
@export var num_characters: int

var character_prefab: PackedScene = preload("res://MainScenes/main_menu_background/character.tscn")

var _current_background_index: int = 0
var logged_in_user: String = ""


func _ready() -> void:
	panel_fader.modulate.a = 0.0
	wait_timer.timeout.connect(_fade_out)
	
	_create_new_characters()
	wait_timer.start()
	
	SignalBus.connect_to_signal("user_logged_in", on_user_logged_in)


func on_user_logged_in(_name: String, _is_forsaken: bool) -> void:
	if _name and _name.length() >= 2:
		logged_in_user = _name.left(2)


func _fade_in() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(panel_fader, "modulate:a", 0.0, fade_time)
	tween.tween_callback(_on_fade_in_complete)


func _fade_out() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(panel_fader, "modulate:a", 1.0, fade_time)
	tween.tween_callback(_on_fade_out_complete)


func _on_fade_in_complete() -> void:
	wait_timer.start()


func _on_fade_out_complete() -> void:
	_empty_folder()
	_swap_background()
	_create_new_characters()
	_fade_in()


func _empty_folder() -> void:
	for child in characters_folder.get_children():
		child.queue_free()


func _swap_background() -> void:
	_current_background_index += 1
	
	if _current_background_index == BACKGROUND_IMAGES.size():
		_current_background_index = 0
	
	background_texture.texture = BACKGROUND_IMAGES[_current_background_index]


func _create_new_characters() -> void:
	for i in range(num_characters + randi() % num_characters):
		var new_character = character_prefab.instantiate()
		
		new_character.move_time = (randf() + 0.5) * 2 # 1.0-2.0
		
		new_character.text = ALPHABET_STRING[randi() % ALPHABET_STRING.length()] + ALPHABET_STRING[randi() % ALPHABET_STRING.length()]
		if i == 0:
			if logged_in_user:
				new_character.text = logged_in_user
			else:
				new_character.text = new_character.text.capitalize()
			new_character.move_time /= 4.0
		
		
		var rand_position = Vector2i(randi_range(0, 41), randi_range(0, 35))
		new_character.position = 24 * rand_position + Vector2i(7, -8)
		
		characters_folder.add_child(new_character)
