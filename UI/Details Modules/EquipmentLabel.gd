extends Label

func _ready() -> void:
	SignalBus.connect_to_signal("equipment_changed", on_equipment_changed)


func on_equipment_changed(_equipment) -> void:
	var equipment: Array[String] = []
	
	if _equipment["talisman"] != "None":
		equipment.append(_equipment["talisman"])
	
	if _equipment["cape"] != "None":
		equipment.append(_equipment["cape"])
	
	if _equipment["boots"] != "None":
		equipment.append(_equipment["boots"])

	if equipment.size() == 0:
		self.text = "No equipment"
	else:
		self.text = ", ".join(equipment)
