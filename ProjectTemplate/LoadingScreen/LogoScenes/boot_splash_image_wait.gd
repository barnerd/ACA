extends BootSplash


func display_logo() -> void:
	await get_tree().create_timer(2.0).timeout
	
	SceneManager.load_next_bootsplash()
