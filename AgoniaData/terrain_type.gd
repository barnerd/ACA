class_name TerrainType extends Resource

const TERRAIN_ID_INTERNAL_TO_APF: Array[int] = [5, 14, 4, 11, 7, 8, 9, 2, 1, 6, 12, 13, 0, 3, 10]
const TERRAIN_ID_APF_TO_INTERNAL: Array[int] = [12, 8, 7, 13, 2, 0, 9, 4, 5, 6, 14, 3, 10, 11, 1]

@export_category("Terrain Details")
@export var terrain_name: String
@export var terrain_id: int
@export var terrain_color_default: Color
@export var terrain_color_custom: Color

@export_group("Order Tribes")
@export var dwarr_mvp: int
@export var leafborn_mvp: int
@export var lightfoot_mvp: int
@export var mythos_mvp: int

@export_group("Forsaken Tribes")
@export var norsk_mvp: int
@export var giant_mvp: int
@export var kiith_mvp: int
@export var nuruk_mvp: int
