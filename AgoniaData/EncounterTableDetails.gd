class_name EncounterTableDetails

var internal_id: int
var internal_id_confirmed: bool
var encounter_id: String # str(terrain_id) + "|" + tier
var terrain_id: int
var tier_name: String
var tier_number: int
var nickname: String

var monsters: Array[int]


func _init(_id: int, _tier: String, _name: String = "", _mons: Array[int] = [], _internal: int = -1, _confirmed: bool = false):
	internal_id = _internal
	internal_id_confirmed = _confirmed

	terrain_id = _id
	tier_name = _tier
	nickname = _name
	
	tier_number = int(tier_name.split(" ")[0].right(-1))
	
	encounter_id = str(terrain_id) + "|" + tier_name
	
	monsters = _mons
