extends Node

var astar_grid: AgoniaAStarGrid2D
var start_point: Vector2i = Vector2i.ONE * -1
var end_point: Vector2i = Vector2i.ONE * -1
var max_tier: int = 99

@onready var path_cost_value = $"../../HBoxContainer/Left Column/Path Cost/Value"

@onready var start_point_field_x = $"../../HBoxContainer/Left Column/Start Point/X"
@onready var start_point_field_y = $"../../HBoxContainer/Left Column/Start Point/Y"
@onready var end_point_field_x = $"../../HBoxContainer/Left Column/End Point/X"
@onready var end_point_field_y = $"../../HBoxContainer/Left Column/End Point/Y"

signal new_path_found(path: Array[Vector2i], cost: int)


func _init() -> void:
	SignalBus.register_signal("new_path_found", new_path_found)
	
	astar_grid = AgoniaAStarGrid2D.new()
	astar_grid.region = Rect2i(0, 0, AgoniaData.MapData.MAP_SIZE.x, AgoniaData.MapData.MAP_SIZE.y)
	#astar_grid.cell_size = Vector2(16, 16)
	astar_grid.update()


func _ready() -> void:
	SignalBus.connect_to_signal("savefile_loaded", set_obstacles)
	SignalBus.connect_to_signal("tribe_selected", on_tribe_selected)
	SignalBus.connect_to_signal("equipment_changed", on_equipment_changed)
	SignalBus.connect_to_signal("pathfinding_max_encounter_tier_selected", on_pathfinding_max_encounter_tier_selected)


func on_tribe_selected(_tribe: String) -> void:
	astar_grid.tribe = _tribe
	
	# if tribe change matters:
	set_obstacles()


func set_obstacles() -> void:
	for loc in AgoniaData.MapData.map_tiles:
		var is_solid: bool = false
		if AgoniaData.MapData.map_tiles[loc].terrain_id != -1:
			var terrain_details = AgoniaData.MapData.terrains_by_id[AgoniaData.MapData.map_tiles[loc].terrain_id]
			if terrain_details.dwarr_mvp == -1:
				is_solid = true
			
		if AgoniaData.MapData.map_tiles[loc].encounter_table_id:
			var encounter_table_id = AgoniaData.MapData.map_tiles[loc].encounter_table_id
			
			var encounter = AgoniaData.MonsterData.get_encounter_table_by_id(encounter_table_id)
			var tier = encounter.tier_number
			
			if tier > max_tier:
				is_solid = true
		
		astar_grid.set_point_solid(Vector2i(loc.x, loc.y), is_solid)


func on_equipment_changed(_equipment) -> void:
	#print(_equipment)
	astar_grid.equipment = _equipment


func on_pathfinding_max_encounter_tier_selected(_max_tier: int) -> void:
	#print(_max_tier)
	max_tier = _max_tier
	
	set_obstacles()


func _on_calculate_button_pressed() -> void:
	print("calculate button")
	
	_get_points()
	print(start_point)
	print(end_point)
	
	if not start_point == Vector2i.ONE * -1 && not end_point == Vector2i.ONE * -1:
		var astar_path = astar_grid.get_id_path(start_point, end_point)
		print(astar_path)
		var path_cost = astar_grid.get_path_cost(astar_path)
		if astar_path.size() == 0:
			path_cost_value.text = "no path"
		else:
			path_cost_value.text = "%d mvp" % path_cost
		print("cost: %f" % path_cost) # 564
		
		new_path_found.emit(astar_path, path_cost)


func _get_points() -> void:
	if (start_point_field_x.text and start_point_field_x.text.is_valid_int() and 
	start_point_field_y.text and start_point_field_y.text.is_valid_int()):
		start_point = Vector2i(int(start_point_field_x.text), int(start_point_field_y.text))
	
	if (end_point_field_x.text and end_point_field_x.text.is_valid_int() and 
	end_point_field_y.text and end_point_field_y.text.is_valid_int()):
		end_point = Vector2i(int(end_point_field_x.text), int(end_point_field_y.text))
