extends Label

@export var main_scene_path: String


func _init() -> void:
	visible = SaveGame.has_save()


func _on_continue_button_pressed() -> void:
	SceneManager.load_scene(main_scene_path)
