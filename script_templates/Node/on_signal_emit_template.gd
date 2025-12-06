# meta-name: On Signal Emit Action
# meta-description: For responding to a signal emitting
# meta-default: true
# meta-space-indent: 4
extends _BASE_

# fill out signal name
var signal_name: String = "signal_name"


func _ready() -> void:
	SignalBus.connect_to_signal(signal_name, on_signal_emit)


func on_signal_emit() -> void:
	pass
