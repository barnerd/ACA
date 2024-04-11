class_name EncounterLayer extends Container

var encounter_label = preload("res://encounter_label.tscn")
@onready var _timer = $Timer

var labels_by_coords: Dictionary = {}

signal generate_encounter_labels_progress(progress: float)
signal generate_encounter_labels_completed()


func _init() -> void:
	SignalBus.register_signal("generate_encounter_labels_progress", generate_encounter_labels_progress)
	SignalBus.register_signal("generate_encounter_labels_completed", generate_encounter_labels_completed)


func _ready() -> void:
	SignalBus.connect_to_signal("savefile_loaded", _generate_labels)
	SignalBus.connect_to_signal("show_encounter_layer_toggled", show_layer)


func show_layer(_on: bool) -> void:
	if _on:
		self.show()
	else:
		self.hide()


func _generate_labels() -> void: #_center: Vector3i = Vector3i(200, 200, 0)
	print("generating encounter labels")
	for y in range(1, 350+1):
		print("generating labels for %s" % y)
		for x in range(1, 350+1):
#	for y in range(150, 200):
#		print("generating labels for %s" % y)
#		for x in range(250, 300):
			var tile = MapDetailsSingleton.map_tiles[Vector3i(x, y, 0)]
			
			var tier = "-1"
			var tile_terrain = tile.terrain_id
			
			if tile.encounter_table_id:
				var encounter = MonsterDetailsSingleton.get_encounter_table_by_id(tile.encounter_table_id)
				
				tier = encounter.tier_number
			
			# don't generate labels for water, snow L2, mountain L3, cap, arena
			if not [1,6,11,12,14].has(tile_terrain) and not labels_by_coords.has(Vector3i(x, y, 0)):
				_create_label(Vector3i(x, y, 0), str(tier))
		
		generate_encounter_labels_progress.emit(100.0 * y / 350+1)
		# yeild control and wait for short time
		_timer.start()
		await _timer.timeout
	
	print("finished generating encounter labels")
	generate_encounter_labels_completed.emit()


func _create_label(_loc: Vector3i, _text: String) -> void:
	var instance = encounter_label.instantiate()
	instance.visible = true
	instance.text = _text
	instance.position = Vector2i(_loc.x*24, _loc.y*24)
	self.add_child(instance)
	labels_by_coords[_loc] = instance


func update_labels(_coords: Array[Vector3i]) -> void:
	for c in _coords:
		if labels_by_coords.has(c):
			var tile = MapDetailsSingleton.map_tiles[c]
			var tier = "-1"
			
			if tile.encounter_table_id:
				var encounter = MonsterDetailsSingleton.get_encounter_table_by_id(tile.encounter_table_id)
				tier = encounter.tier_number
			labels_by_coords[c].text = str(tier)
