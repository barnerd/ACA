class_name TownDetails

enum Dwelling_Sizes {UNKNOWN, NONE, HUNDRED, FIVE_HUNDRED}
enum Buildings {BLACKSMITH = 0x0001, WORKSHOP = 0x0010, ALCHEMICAL_LAB = 0x0100, WONDERS = 0x1000}

var town_id: int
var town_name: String

var group_id: int

var location: Vector3i

var watchtower_view: int # [-1, 4]
var dwelling_size: Dwelling_Sizes

# binary bitmask for buildings
# setting: bitmask = bitmask ^ BLACKSMITH
# checking: if bitmask & FLAG_C:
var buildings_bitmask: int 


func _init(_town_id: int, _name: String, _group_id: int, _loc: Vector3i, _watchtower: int = -1, _dwelling: Dwelling_Sizes = Dwelling_Sizes.UNKNOWN, _buildings: int = -1):
	town_id = _town_id
	town_name = _name
	group_id = _group_id
	
	location = _loc
	
	watchtower_view = _watchtower
	dwelling_size = _dwelling
	buildings_bitmask = _buildings
	
	# limit watchtower value
	if watchtower_view > 4 || watchtower_view < 0:
		watchtower_view = -1
