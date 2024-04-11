class_name EncounterLayer extends Container

var encounter_label = preload("res://encounter_label.tscn")
@onready var _timer = $Timer

var labels_by_coords: Dictionary = {}

signal generate_encounter_labels_progress(progress: float)
signal generate_encounter_labels_completed()

var min_tier_to_display: int = 5


func _init() -> void:
	SignalBus.register_signal("generate_encounter_labels_progress", generate_encounter_labels_progress)
	SignalBus.register_signal("generate_encounter_labels_completed", generate_encounter_labels_completed)


func _ready() -> void:
	SignalBus.connect_to_signal("savefile_loaded", _generate_labels)
	SignalBus.connect_to_signal("show_encounter_layer_toggled", show_layer)
	SignalBus.connect_to_signal("min_encounter_tier_selected", on_min_tier_selected)


func show_layer(_on: bool) -> void:
	if _on:
		self.show()
	else:
		self.hide()


func on_min_tier_selected(_tier: int) -> void:
	min_tier_to_display = _tier
	
	for l in labels_by_coords.values():
		# remove BBCode
		var regex = RegEx.new()
		regex.compile("\\[.*?\\]")
		var text_without_tags = regex.sub(l.text, "", true)
		var label_tier:int = int(text_without_tags)
		
		if label_tier < min_tier_to_display:
			l.hide()
		else:
			l.show()


func _generate_labels() -> void: #_center: Vector3i = Vector3i(200, 200, 0)
	print("generating encounter labels")
	for y in range(1, 350+1):
		print("generating labels for %s" % y)
		for x in range(1, 350+1):
#	for y in range(150, 200):
#		print("generating labels for %s" % y)
#		for x in range(250, 300):
			var tile = MapDetailsSingleton.map_tiles[Vector3i(x, y, 0)]
			
			var tier: int = -1
			var tile_terrain = tile.terrain_id
			
			if tile.encounter_table_id:
				var encounter = MonsterDetailsSingleton.get_encounter_table_by_id(tile.encounter_table_id)
				
				tier = encounter.tier_number
			
			# don't generate labels for water, snow L2, mountain L3, cap, arena
			if not [1,6,11,12,14].has(tile_terrain) and not labels_by_coords.has(Vector3i(x, y, 0)):
				# use black text if on snow, icy 1, else white
				_create_label(Vector3i(x, y, 0), tier, Color.BLACK if [9, 10].has(tile_terrain) else Color.WHITE)
		
		generate_encounter_labels_progress.emit(100.0 * y / 350+1)
		# yeild control and wait for short time
		_timer.start()
		await _timer.timeout
	
	print("finished generating encounter labels")
	generate_encounter_labels_completed.emit()


func _create_label(_loc: Vector3i, _tier: int, _color: Color = Color.WHITE) -> void:
	var instance = encounter_label.instantiate()
	# if tier is higher than visible, turn on
	if _tier < min_tier_to_display:
		instance.visible = false
	else:
		instance.visible = true
	instance.text = "[color=#%s]%d[/color]" % [_color.to_html(), _tier]
	instance.position = Vector2i(_loc.x*24, _loc.y*24)
	self.add_child(instance)
	labels_by_coords[_loc] = instance


func update_labels(_coords: Array[Vector3i]) -> void:
	for c in _coords:
		if labels_by_coords.has(c):
			var tile = MapDetailsSingleton.map_tiles[c]
			var terrain = tile.terrain_id
			var color = Color.BLACK if [9, 10].has(terrain) else Color.WHITE
			var tier: int = -1
			
			if tile.encounter_table_id:
				var encounter = MonsterDetailsSingleton.get_encounter_table_by_id(tile.encounter_table_id)
				tier = encounter.tier_number
			labels_by_coords[c].text = "[color=#%s]%s[/color]" % [color.to_html(), tier]
			
			# if tier is higher than visible, turn on
			if tier < min_tier_to_display:
				labels_by_coords[c].hide()
			else:
				labels_by_coords[c].show()
