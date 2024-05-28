extends OptionButton

signal pathfinding_max_encounter_tier_selected(max_tier: int)


func _init() -> void:
	SignalBus.register_signal("pathfinding_max_encounter_tier_selected", pathfinding_max_encounter_tier_selected)


func _on_item_selected(index: int) -> void:
	pathfinding_max_encounter_tier_selected.emit(get_item_id(index))
