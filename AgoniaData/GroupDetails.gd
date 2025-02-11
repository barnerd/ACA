class_name GroupDetails

enum Factions {ORDER, FORSAKEN, FREE_FOLK}
const Faction_Names: Array[String] = ["Order", "Forsaken", "Free Folk"]

var group_id: int
var group_name: String
var group_faction: Factions

var towns: Array[TownDetails] = []


func _init(_id: int, _name: String, _faction: Factions):
	group_id = _id
	group_name = _name
	group_faction = _faction


func add_town(_town: TownDetails):
	towns.append(_town)
