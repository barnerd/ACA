class_name EncounterTableDetails extends Node

var encounter_id: String # str(terrain_id) + "|" + tier
var terrain_id: int
var tier_name: String
var tier_number: int
var nickname: String

var monsters: Array[int]


func _init(_id: int, _tier: String, _name: String = "", _mons: Array[int] = []):
	terrain_id = _id
	tier_name = _tier
	nickname = _name
	
	tier_number = int(tier_name.split(" ")[0].right(-1))
	
	encounter_id = str(terrain_id) + "|" + tier_name
	
	monsters = _mons
