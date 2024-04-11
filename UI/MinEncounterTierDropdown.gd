extends OptionButton

signal min_encounter_tier_selected(_tier: int)


func _init() -> void:
	SignalBus.register_signal("min_encounter_tier_selected", min_encounter_tier_selected)


func _ready() -> void:
	SignalBus.connect_to_signal("generate_encounter_labels_completed", _on_generation_completed)


func _on_generation_completed() -> void:
	self.disabled = false


func _on_item_selected(index: int) -> void:
	min_encounter_tier_selected.emit(index+1)
