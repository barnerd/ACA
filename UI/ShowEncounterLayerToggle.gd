extends CheckButton

signal show_encounter_layer_toggled(_pressed: bool)


func _init() -> void:
	SignalBus.register_signal("show_encounter_layer_toggled", show_encounter_layer_toggled)


func _ready() -> void:
	SignalBus.connect_to_signal("generate_encounter_labels_progress", _on_generation_progress)
	SignalBus.connect_to_signal("generate_encounter_labels_completed", _on_generation_completed)


func _on_generation_progress(_percent: float) -> void:
	self.text = "Loading... %0.2f%%" % _percent


func _on_generation_completed() -> void:
	self.text = "Show Encounters"
	self.disabled = false


func _on_toggled(toggled_on: bool) -> void:
	show_encounter_layer_toggled.emit(toggled_on)
