class_name MonsterDataBase extends Node

var monsters_by_id: Dictionary[int, MonsterResource]
var encounters_by_id: Dictionary[int, EncounterResource]
#var encounters_by_terrain_tier: Dictionary = {} # int -> String -> EncounterTable

var have_changes_to_save: bool


func _init() -> void:
	have_changes_to_save = false
	
	monsters_by_id = {}
	
	load_monster_resources("res://resources/monsters/", monsters_by_id)
	load_encounter_resources("res://resources/encounters/", encounters_by_id)


func get_encounter_by_terrain_tier(_terrain: int, _tier: String) -> EncounterResource:
	for encounter in encounters_by_id.values():
		if encounter.terrain_id == _terrain && encounter.tier_name == _tier:
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

#func load_encounter_resources(_path: String, _dic: Dictionary) -> void:
	#var dir = DirAccess.open(_path)
	#if dir:
		#dir.list_dir_begin()
		#var file_name = dir.get_next()
		#while file_name != "":
			#var loaded_resource = load(_path + file_name) as EncounterResource
			#_dic[loaded_resource.id] = loaded_resource
			#file_name = dir.get_next()
