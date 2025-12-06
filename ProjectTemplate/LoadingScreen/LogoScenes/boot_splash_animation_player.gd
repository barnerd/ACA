extends BootSplash

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func display_logo() -> void:
	animation_player.play("display_logo")
	
	await animation_player.animation_finished
	SceneManager.load_next_bootsplash()
