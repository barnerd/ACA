class_name AgoniaAStarGrid2D extends AStarGrid2D

var equipment = {"talisman": "None", "cape": "None", "boots": "None"}
var cost_lower_bound: float = 5
var tribe: String = "Dwarr"


func _compute_cost(from_id: Vector2i, to_id: Vector2i) -> float:
	#print("compute cost")
	#print("From: %v to %v" % [from_id, to_id])
	var target_tile: TileDetails = AgoniaData.MapData.map_tiles[Vector3i(to_id.x, to_id.y, 0)]
	var terrain: TerrainType = AgoniaData.MapData.terrains_by_id[target_tile.terrain_id]
	
	var cost: float = _get_tribe_cost(terrain, tribe)
	
	assert(cost != -1)
	
	if equipment["talisman"] == "Sapphire Stamina":
		cost -= 1
	elif equipment["talisman"] == "Diamond Stamina":
		cost -= 2
	
	if equipment["cape"] == "Wheelcart":
		cost += 7
	elif equipment["cape"] == "Wagon":
		cost += 100
		# if road, capital
		if [8, 12].has(terrain.terrain_id):
			cost -= 88
	
	if equipment["boots"] == "Crampons":
		if [10].has(terrain.terrain_id):
			cost -= 100
	
	if equipment.has("max_weight") && equipment.has("total_weight"):
		var weight_percent: float = equipment["total_weight"] / float(equipment["max_weight"])
		cost *= clampf(weight_percent, 1.0, 1.5)
	
	# either 1 or sqrt(2)
	var distance: float = _distance(from_id, to_id)
	#print(distance)
	
	return floori(cost * abs(distance))


func _estimate_cost(from_id: Vector2i, to_id: Vector2i) -> float:
	#print("estimate cost")
	# not in current version yet: https://github.com/godotengine/godot-proposals/issues/2297
	# var distance: float = from_id.distance_to(to_id)
	var distance: float = _distance(from_id, to_id)
	
	return distance * cost_lower_bound


func _distance(from_id: Vector2i, to_id: Vector2i) -> float:
	var dx: int = to_id.x - from_id.x
	var dy: int = to_id.y - from_id.y

	var distance: float = sqrt(dx * dx + dy * dy)
	
	return distance


func _get_tribe_cost(_terrain: TerrainType, _tribe: String) -> int:
	var cost: int
	
	match _tribe:
		"Dwarr":
			cost = _terrain.dwarr_mvp
		"Leafborn":
			cost = _terrain.leafborn_mvp
		"Lightfoot":
			cost = _terrain.lightfoot_mvp
		"Mythos":
			cost = _terrain.mythos_mvp
		"Norsk":
			cost = _terrain.norsk_mvp
		"Giant":
			cost = _terrain.giant_mvp
		"Kiith":
			cost = _terrain.kiith_mvp
		"Nuruk":
			cost = _terrain.nuruk_mvp
	
	return cost


# feature request: https://github.com/godotengine/godot-proposals/issues/5667
func get_path_cost(_path: Array[Vector2i]) -> int:
	var cost: int = 0
	var from_id
	
	if _path.size() > 0:
		from_id = _path[0]
	
	for i in range(1, _path.size()):
		cost += roundi(_compute_cost(from_id, _path[i]))
		#print(cost)
		from_id = _path[i]
	
	return cost
