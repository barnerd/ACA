extends Button

signal clear_path


func _init() -> void:
	SignalBus.register_signal("clear_path", clear_path)


func _on_pressed() -> void:
	clear_path.emit()
