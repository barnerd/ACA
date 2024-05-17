class_name MineDetails extends Node

enum Mine_Types {TIN = 0, COPPER = 1, IRON = 2, TITANIUM = 3}
const mine_names: Array[String] = ["Tin", "Copper", "Iron", "Titanium"]

var location: Vector3i
var type: Mine_Types
var type_name: String
var is_permanent: bool


func _init(_type: Mine_Types, _loc = Vector3i.ZERO, _perm: bool = false):
	location = _loc
	
	type = _type
	type_name = mine_names[_type]
	
	is_permanent = _perm
