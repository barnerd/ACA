extends Button

@onready var auth_node = $"../AuthNode"

signal user_logged_out


func _init() -> void:
	SignalBus.register_signal("user_logged_out", user_logged_out)


func _ready() -> void:
	SignalBus.connect_to_signal("user_logged_in", on_user_logged_in)


func _on_pressed() -> void:
	auth_node.revoke_token()
	self.visible = false
	user_logged_out.emit()
	$"../LoadAgonia".visible = false
	$"../StatusLabel".text = "Please login"


func on_user_logged_in(_name, _is_forsaken) -> void:
	if _is_forsaken:
		self.visible = true
