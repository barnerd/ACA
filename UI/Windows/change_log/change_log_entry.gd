@tool
class_name ChangeLogEntry extends VBoxContainer

@export_group("Version")
@export var major_version: int
@export var minor_version: int
@export var release_version: int

@export_group("Entry")
@export var entry_header: String
@export_multiline var entry_log: String

@onready var header_field: Label = $"Header"
@onready var log_field: Label = $"Log"


func _ready() -> void:
	header_field.text = "v%d.%d.%d - %s" % [major_version, minor_version, release_version, entry_header]
	log_field.text = entry_log


func highlight(last_seen: Dictionary) -> void:
	var this_version = {}
	this_version["major"] = major_version
	this_version["minor"] = minor_version
	this_version["release"] = release_version
	
	if _compare_version(this_version, last_seen) > 0:
		header_field.text += " - NEW!"


func _compare_version(_a, _b) -> int:
	if _a.major > _b.major:
		return 1
	elif _a.major < _b.major:
		return -1
	else:
		if _a.minor > _b.minor:
			return 1
		elif _a.minor < _b.minor:
			return -1
		else:
			if _a.release > _b.release:
				return 1
			elif _a.release < _b.release:
				return -1
			else:
				return 0
