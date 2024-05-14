class_name OrderViewParser extends Node

var regex: RegEx
var map_table_data: String

@onready var results_textbox = $"../Update Map Results PopupPanel/VBoxContainer/Results"
@onready var status_textbox = $"../Update Map Results PopupPanel/VBoxContainer/HBoxContainer/Status"

var counts: Dictionary = {}
var pending_changes: Array = []


func _init() -> void:
	regex = RegEx.new()


func _on_parse_button_pressed() -> void:
	counts = {}
	pending_changes = []
	status_textbox.text = "Parsing..."
	print("Parsing Order side")
	
	# check for <table> tag, and anything else
	# \\s\\S for multiline
	# /? to match /
	regex.compile("<table><tbody>([./n/r\\s\\S]*)</?tbody></?table>")

	var result = regex.search($"../VBoxContainer/TextEdit".text)
	if result:
		map_table_data = result.get_string(1)
		update_results()
		#parse_map_table(map_table_data)
		add_coords(map_table_data)
	
	status_textbox.text = "Done"
	print("Pending Changes count: " + str(pending_changes.size()))


func _on_cancel_button_pressed() -> void:
	pending_changes = []


func _on_accept_button_pressed() -> void:
	for change in pending_changes:
		AgoniaData.MapData.update_location(Vector3i(change["x"], change["y"], change["z"]), change["terrain_id"], change["map_id"])
	AgoniaData.MapData.terrain_colors_display.apply_image()


func add_coords(_data: String):
	var x: int = 164
	var y: int = 80
	
	regex.compile("<tr(.*>[.\\s\\S]*?)</?tr>")
	var tr_results = regex.search_all(_data)
	if tr_results.size() > 0:
		
		for trow in tr_results:
			y += 1
			x = 164
			print("y: "+str(y))
			
			regex.compile("<td(.*)></?td>")
			var td_results = regex.search_all(trow.get_string())
			if td_results.size() > 0:
				
				for td in td_results:
					# this is x, y
					#print("("+str(x)+","+str(y)+")")
					
					# find map id
					var map_id: int
					#<td background="https://static.agonialands.com/assets/map/1154.gif"></td>
					regex.compile("map/?(.*).gif")
					
					var map_results = regex.search(td.get_string())
					if map_results:
						map_id = int(map_results.get_string(1))
					
						# query TileSet for terrain Id
						var tileset_coords = Vector2i(map_id % 76, floor(map_id / 76.0))
						var tileset_terrain_id = int(AgoniaData.MapData.tile_map_display.tile_set.get_source(0).get_tile_data(tileset_coords, 0).get_custom_data("terrain_id"))
						
						# query MapDetailsSingleton for terrain id
						var map_details_terrain_id
						var map_details_map_id
						if AgoniaData.MapData.map_tiles.has(Vector3i(x, y, 0)):
							map_details_terrain_id = AgoniaData.MapData.map_tiles[Vector3i(x, y, 0)].terrain_id
							map_details_map_id = AgoniaData.MapData.map_tiles[Vector3i(x, y, 0)].tile_image_id
						
						# if terrain Id's match, then append to pending
						if map_details_map_id == -1 && tileset_terrain_id == map_details_terrain_id:
							pending_changes.append({"x": x,
							"y": y,
							"z": 0,
							"terrain_id": map_details_terrain_id,
							"map_id": map_id})
							#print("("+str(x)+","+str(y)+") = " + str(map_id))
						#else:
							#print("("+str(x)+","+str(y)+") map-"+str(map_id)+" mismatch: " + str(tileset_terrain_id) + "!=" + str(map_details_terrain_id))
					
					x += 1


# <td class="map-84" data-x="222" data-y="130" style="width:24px; height:24px; display: inline-block"></td>
func parse_map_table(_data: String):
	regex.compile("<td(.*>[.\\s\\S]*?)</?td>")
	
	var results = regex.search_all(_data)
	if results.size() > 0:
		counts["nodes"] = results.size()
		update_results()
		
		for td in results:
			regex.compile("class=\"map-(\\d+)\" data-x=\"(\\d+)\" data-y=\"(\\d+)\".*?>([.\\s\\S]*?)</?td>")
			
			#print(td.get_string())
			var td_result = regex.search(td.get_string())
			if td_result:
				#print("map-" + td_result.get_string(1) + ", x=" + td_result.get_string(2) + ", y=" + td_result.get_string(3))
				# found map-, x, y, check if this is a change
				var tile_details = {}
				tile_details["location"] = Vector3i(int(td_result.get_string(2)), int(td_result.get_string(3)), 0)
				tile_details["map_id"] = int(td_result.get_string(1))

				var tileset_coords = Vector2i(tile_details["map_id"] % 76, floor(tile_details["map_id"] / 76))
				var tileset_details = AgoniaData.MapData.tile_map_display.tile_set.get_source(0).get_tile_data(Vector2i(tileset_coords.x, tileset_coords.y), 0).get_custom_data("terrain_id")
				#print(tileset_details)
				tile_details["terrain_id"] = int(tileset_details)
				
				if AgoniaData.MapData.map_tiles.has(tile_details["location"]):
					if AgoniaData.MapData.map_tiles[tile_details["location"]].tile_image_id != tile_details["map_id"] || AgoniaData.MapData.map_tiles[tile_details["location"]].terrain_id != tile_details["terrain_id"]:
						#print("New info!")
						pending_changes.append({"x": tile_details["location"].x,
						"y": tile_details["location"].y,
						"z": tile_details["location"].z,
						"map_id": tile_details["map_id"],
						"terrain_id": tile_details["terrain_id"]})
						_increment_counts("pending")
					else:
						#print("Duplicated info!")
						_increment_counts("duplicates")
				else:
					#print("New info!")
					pending_changes.append({"x": tile_details["location"].x,
					"y": tile_details["location"].y,
					"z": tile_details["location"].z,
					"map_id": tile_details["map_id"],
					"terrain_id": tile_details["terrain_id"]})
					_increment_counts("pending")



func _increment_counts(_key: String):
	if counts.has(_key):
		counts[_key] += 1
	else:
		counts[_key] = 1


func update_results():
	if counts.has("nodes"):
		results_textbox.text = str(counts["nodes"]) + " tiles found...\n\n"
	else: 
		results_textbox.text = "0 nodes found...\n\n"
	
	if counts.has("terrains"):
		results_textbox.text = results_textbox.text + str(counts["terrains"]) + " terrains to double check\n"
	if counts.has("paths"):
		results_textbox.text = results_textbox.text + str(counts["paths"]) + " path markers found\n"
	if counts.has("characters"):
		results_textbox.text = results_textbox.text + str(counts["characters"]) + " characters found\n"
	if counts.has("towns"):
		results_textbox.text = results_textbox.text + str(counts["towns"]) + " towns to store\n"
	if counts.has("mines"):
		results_textbox.text = results_textbox.text + str(counts["mines"]) + " mines to store\n"
	if counts.has("warnings"):
		results_textbox.text = results_textbox.text + str(counts["warnings"]) + " warnings to check\n"

	results_textbox.text = results_textbox.text + "\n"
	if counts.has("pending"):
		results_textbox.text = results_textbox.text + str(counts["pending"]) + " pending changes to make\n"
	if counts.has("duplicates"):
		results_textbox.text = results_textbox.text + str(counts["duplicates"]) + " duplicate tiles to discard\n"
