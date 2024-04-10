class_name EncounterLayer extends Container

var encounter_label = preload("res://encounter_label.tscn")

var labels_by_coords: Dictionary = {}


func _ready() -> void:
	SignalBus.connect_to_signal("savefile_loaded", _generate_labels)


func _generate_labels() -> void: #_center: Vector3i = Vector3i(200, 200, 0)
	print("generating encounter labels")
#	for y in range(1, 350+1):
#		print("generating labels for %s" % y)
#		for x in range(1, 350+1):
#	for y in range(150, 200):
#		print("generating labels for %s" % y)
#		for x in range(250, 300):
	for y in range(100, 250):
		print("generating labels for %s" % y)
		for x in range(200, 350):
			var tile = MapDetailsSingleton.map_tiles[Vector3i(x, y, 0)]
			
			var tier = "-1"
			var tile_terrain = tile.terrain_id
			
			if tile.encounter_table_id:
				var encounter = MonsterDetailsSingleton.get_encounter_table_by_id(tile.encounter_table_id)
				
				tier = encounter.tier_number
			
			# don't generate labels for water, snow L2, mountain L3, cap, arena
			if not [1,6,11,12,14].has(tile_terrain) and not labels_by_coords.has(Vector3i(x, y, 0)):
				var instance = encounter_label.instantiate()
				instance.visible = false
				#if y in range(150, 200) and x in range(250, 300):
				instance.visible = true
				instance.text = str(tier)
				instance.position = Vector2i(x*24, y*24)
				self.add_child(instance)
				labels_by_coords[Vector3i(x, y, 0)] = instance
	
	print("finished generating encounter labels")


func update_labels(_coords: Array[Vector3i]) -> void:
	for c in _coords:
		if labels_by_coords.has(c):
			var tile = MapDetailsSingleton.map_tiles[c]
			var tier = "-1"
			
			if tile.encounter_table_id:
				var encounter = MonsterDetailsSingleton.get_encounter_table_by_id(tile.encounter_table_id)
				tier = encounter.tier_number
			labels_by_coords[c].text = str(tier)
