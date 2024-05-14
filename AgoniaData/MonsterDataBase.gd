class_name MonsterDataBase extends Node

@onready var encounter_layer: EncounterLayer = $/root/Node2D/Control/PanelContainer/VBoxContainer/HBoxContainer/ScrollContainer/Control/PanelContainer/EncounterLayer

var monsters_by_id: Dictionary = {} # int -> MonsterDetails
var encounters_by_terrain_tier: Dictionary = {} # int -> String -> EncounterTable

var have_changes_to_save: bool


func _init() -> void:
	have_changes_to_save = false


func save():
	# save monster data
	var save_monsters: Array = []
	for m in monsters_by_id.values():
		save_monsters.append({
			"id": m.monster_id,
			"n": m.monster_name,
			"c": m.monster_category,
			"h": m.monster_health,
			"exp": m.exp_per_hit,
			"s": m.sorcery_requirement
		})
	
	# save encounter data
	var save_encounters: Array = []
	for terrain_id in encounters_by_terrain_tier:
		for tier in encounters_by_terrain_tier[terrain_id]:
			save_encounters.append({
				"t_id": terrain_id,
				"t": tier,
				"n": encounters_by_terrain_tier[terrain_id][tier].nickname,
				"m": encounters_by_terrain_tier[terrain_id][tier].monsters
			})
	
	var save_dict = {
		"node_path": self.get_path(),
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"monsters" : save_monsters,
		"encounters" : save_encounters
	}
	
	have_changes_to_save = false
	
	return save_dict


func load(_data):
	print("loading monsters & encounters details")
	monsters_by_id = {} # int -> MonsterDetails
	
	# load monster data
	for m in _data["monsters"]:
		update_monster(m["id"], m["n"], m["s"], m["c"], m["h"], m["exp"]) 
	
	# load encounter data
	encounters_by_terrain_tier = {} # int -> String -> EncounterTable
	for e in _data["encounters"]:
		var mon_int_array: Array[int] = _convert_array_float_to_int(e["m"])
		update_encounter(e["t_id"], e["t"], e["n"], mon_int_array)


# Need this because Json.parse returns all numbers as floats
func _convert_array_float_to_int(_old_array) -> Array[int]:
	var new_array: Array[int] = []
	
	for i in _old_array:
		new_array.append(int(i))
	
	return new_array


func update_monster(_id: int, _name: String, _sorcery_req: int = -1, _monster_category: MonsterDetails.MonsterCategory = MonsterDetails.MonsterCategory.OTHER, _health: int = -1, _expph: int = -1):
	if monsters_by_id.has(_id):
		monsters_by_id[_id].monster_name = _name
		monsters_by_id[_id].monster_category = _monster_category
		monsters_by_id[_id].monster_health = _health
		monsters_by_id[_id].exp_per_hit = _expph
		monsters_by_id[_id].sorcery_requirement = _sorcery_req
	else:
		monsters_by_id[_id] = MonsterDetails.new(_id, _name, _sorcery_req, _monster_category, _health, _expph)


func update_encounter(_terrain_id: int, _tier: String, _name: String = "", _mons: Array[int] = []):
	if encounters_by_terrain_tier.has(_terrain_id):
		if encounters_by_terrain_tier[_terrain_id].has(_tier):
			encounters_by_terrain_tier[_terrain_id][_tier].nickname = _name
			encounters_by_terrain_tier[_terrain_id][_tier].monsters = _mons
		else:
			encounters_by_terrain_tier[_terrain_id][_tier] = EncounterTableDetails.new(_terrain_id, _tier, _name, _mons)
	else:
		encounters_by_terrain_tier[_terrain_id] = {}
		encounters_by_terrain_tier[_terrain_id][_tier] = EncounterTableDetails.new(_terrain_id, _tier, _name, _mons)


func get_encounter_table_by_id(_id: String) -> EncounterTableDetails:
	if _id:
		var string_array = _id.split("|")
		
		var encounter_table: EncounterTableDetails = encounters_by_terrain_tier[int(string_array[0])][string_array[1]]

		return encounter_table
	else:
		return null