class_name MonsterResource extends Resource

enum CATEGORY { EXP, NORMAL, BOSS }

const monster_image_base_url: String = "https://www.agonialands.com/assets/images/monsters/agonia/monster_%d.png" # % monster_id

@export var category: CATEGORY
@export var id: int
@export var monster_name: String

@export var health: int
@export var sorcery_req: int
@export var combat_exp: int
@export var sorcery_exp: int
