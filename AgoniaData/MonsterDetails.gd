class_name MonsterDetails

enum MonsterCategory {EXP = 0, OTHER = 1, BOSS = 2}

var monster_id: int
var monster_image_url: String
var monster_name: String
var monster_category: MonsterCategory
#var monster_type: MonsterType # this is from the Game Guide
#var monster_group: ??
#var monster_description: String
var monster_health: int
var exp_per_hit: int
var sorcery_requirement: int

# consider adding a reference back to Encounters
# var encounters: Array[EncounterTable]

func _init(_id: int, _name: String, _sorcery_req: int = -1, _monster_category: MonsterCategory = MonsterCategory.OTHER, _health: int = -1, _expph: int = -1):
	monster_id = _id
	monster_image_url = "https://www.agonialands.com/assets/images/monsters/agonia/monster_%d.png" % monster_id
	monster_name = _name
	monster_category = _monster_category
	monster_health = _health
	exp_per_hit = _expph
	sorcery_requirement = _sorcery_req
