extends Window


func _ready() -> void:
	SignalBus.connect_to_signal("on_credits_menu_button_pressed", on_credits_menu_button_pressed)


func on_credits_menu_button_pressed() -> void:
	visible = true
