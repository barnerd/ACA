class_name MonsterDataBase extends Node

var monsters_by_id: Dictionary[int, MonsterResource]
var encounters_by_id: Dictionary[int, EncounterResource]


func _init() -> void:
	monsters_by_id = {}
	
	load_monster_resources("res://resources/monsters/", monsters_by_id)
	load_encounter_resources("res://resources/encounters/", encounters_by_id)


func get_encounter_by_terrain_tier(_terrain: int, _tier: String) -> EncounterResource:
	for encounter in encounters_by_id.values():
		if encounter.terrain_id == _terrain and encounter.tier_name == _tier:
			return encounter
	
	return null


func load_monster_resources(_path: String, _dic: Dictionary) -> void:
	for file in ResourceLoader.list_directory(_path):
		var loaded_resource = load(_path + file) as MonsterResource
		_dic[loaded_resource.id] = loaded_resource


func load_encounter_resources(_path: String, _dic: Dictionary) -> void:
	for file in ResourceLoader.list_directory(_path):
		var loaded_resource = load(_path + file) as EncounterResource
		_dic[loaded_resource.id] = loaded_resource
