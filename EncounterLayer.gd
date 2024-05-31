class_name EncounterLayer extends Container

@export var load_labels: bool

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
	if load_labels:
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
	for y in range(0, AgoniaData.MapData.MAP_SIZE.y):
		print("generating labels for %s" % y)
		for x in range(0, AgoniaData.MapData.MAP_SIZE.x):
#	for y in range(150, 200):
#		print("generating labels for %s" % y)
#		for x in range(250, 300):
			var tile = AgoniaData.MapData.map_tiles[Vector3i(x, y, 0)]
			
			var tier: int = -1
			var tile_terrain = tile.terrain_id
			
			if tile.encounter_table_id:
				var encounter = AgoniaData.MonsterData.get_encounter_table_by_id(tile.encounter_table_id)
				
				tier = encounter.tier_number
			
			# don't generate labels for water, snow L2, mountain L3, cap, arena
			if not [1,6,11,12,14].has(tile_terrain) and not labels_by_coords.has(Vector3i(x, y, 0)):
				_create_label(Vector3i(x, y, 0), tier, tile_terrain)
		
		generate_encounter_labels_progress.emit(100.0 * y / AgoniaData.MapData.MAP_SIZE.y)
		
		# yield control and wait for short time
		_timer.start()
		await _timer.timeout
	
	print("finished generating encounter labels")
	generate_encounter_labels_completed.emit()


func _create_label(_loc: Vector3i, _tier: int, _terrain: int) -> void:
	var instance = encounter_label.instantiate()
	# if tier is higher than visible, turn on
	if _tier < min_tier_to_display:
		instance.visible = false
	else:
		instance.visible = true
	
	instance.text = str(_tier)
	_update_theme_variation(_terrain, instance)
	
	# "-4" to move text up a few pixels to better align with terrain bg
	var text_offset: Vector2i = Vector2i(-5, -5)
	instance.position = Vector2i(_loc.x*AgoniaData.MapData.TILE_SIZE.x+text_offset.x, _loc.y*AgoniaData.MapData.TILE_SIZE.y+text_offset.y)
	self.add_child(instance)
	instance.owner = self
	labels_by_coords[_loc] = instance


func update_labels(_coords: Array[Vector3i]) -> void:
	for c in _coords:
		if labels_by_coords.has(c):
			var tile = AgoniaData.MapData.map_tiles[c]
			var terrain = tile.terrain_id
			var tier: int = -1
			
			if tile.encounter_table_id:
				var encounter = AgoniaData.MonsterData.get_encounter_table_by_id(tile.encounter_table_id)
				tier = encounter.tier_number

			labels_by_coords[c].text = str(tier)
			_update_theme_variation(terrain, labels_by_coords[c])
			
			# if tier is higher than visible, turn on
			if tier < min_tier_to_display:
				labels_by_coords[c].hide()
			else:
				labels_by_coords[c].show()


#func _update_theme_variation(_loc: Vector3i, _label: Label) -> void:
func _update_theme_variation(_terrain_id: int, _label: Label) -> void:
	# use black text if on desert, snow, icy 1, else white
	# Color.BLACK if [0,9,10].has(tile_terrain) else Color.WHITE
	
	#var terrain_name: String = ""
	#if AgoniaData.MapData.map_tiles[_loc].terrain_details:
	#	terrain_name = AgoniaData.MapData.map_tiles[_loc].terrain_details.terrain_name
	
	var variation: String = "EncounterLabel"
	if [0,9,10].has(_terrain_id):
		variation = "DarkEncounterLabel"
	
	_label.theme_type_variation = StringName(variation)
