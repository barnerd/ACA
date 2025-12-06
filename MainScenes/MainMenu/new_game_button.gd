extends Label

@export var new_game_scene_path: String

func _on_new_game_button_pressed() -> void:
	SceneManager.load_scene(new_game_scene_path)
