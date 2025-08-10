class_name EncounterResource extends Resource

@export var id: int
@export var internal_id_confirmed: bool
@export var encounter_id: String # str(terrain_id) + "|" + tier_name
@export var terrain_id: int
@export var tier_name: String
@export var tier_number: int #int(tier_name.split(" ")[0].right(-1))
@export var nickname: String

@export var monsters: Array[int]
