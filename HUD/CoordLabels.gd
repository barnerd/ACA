extends BoxContainer

var coord_label = preload("res://HUD/coord_label.tscn")

func _init() -> void:
	for x in range(0, AgoniaData.MapData.MAP_SIZE.x):
		var instance = coord_label.instantiate()
		instance.text = str(x)
		add_child(instance)
