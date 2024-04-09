class_name MapParser extends Node

var regex: RegEx
var map_table_data: String

@onready var results_textbox = $"../Update Map Results PopupPanel/VBoxContainer/Results"
@onready var status_textbox = $"../Update Map Results PopupPanel/VBoxContainer/HBoxContainer/Status"

var counts: Dictionary = {}
var pending_changes: Array = []
var pending_mines: Array = []
var pending_towns: Array = []


func _init() -> void:
	regex = RegEx.new()


func _on_parse_button_pressed() -> void:
	counts = {}
	pending_changes = []
	pending_mines = []
	pending_towns = []
	
	status_textbox.text = "Parsing..."
	
	# check for <table> tag, and anything else
	# \\s\\S for multiline
	# /? to match /
	regex.compile("<table>([./n/r\\s\\S]*)</?table>")

	var result = regex.search($"../VBoxContainer/TextEdit".text)
	if result:
		map_table_data = result.get_string(1)
		update_results()
		parse_map_table(map_table_data)
	
	status_textbox.text = "Done"
	print("Pending Changes count: " + str(pending_changes.size()))


func _on_cancel_button_pressed() -> void:
	pending_changes = []
	pending_mines = []
	pending_towns = []


func _on_accept_button_pressed() -> void:
	for change in pending_changes:
		MapDetailsSingleton.update_location(Vector3i(change["x"], change["y"], change["z"]), change["terrain_id"], change["map_id"])
	MapDetailsSingleton.terrain_colors_display.apply_image()
	
	for mine in pending_mines:
		MapDetailsSingleton.add_mine_location(mine["type"], Vector3i(mine["x"], mine["y"], mine["z"]))
	
	for town in pending_towns:
		MapDetailsSingleton.update_town(-1, "", -1, Vector3i(town["x"], town["y"], town["z"]))
	
	if pending_changes.size() > 0 || pending_mines.size() > 0 || pending_towns.size() > 0:
		MapDetailsSingleton.have_changes_to_save = true


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
				var tileset_details = MapDetailsSingleton.tile_map_display.tile_set.get_source(0).get_tile_data(Vector2i(tileset_coords.x, tileset_coords.y), 0).get_custom_data("terrain_id")
				#print(tileset_details)
				tile_details["terrain_id"] = int(tileset_details)
				
				var td_contents = td_result.get_string(4).strip_edges()
				if td_contents.length() > 0:
					#print("Something found in the td: " + td_contents)
					
					# track if we know what was found
					var found_identified = false
					var result
					
					# combined: 
					#<div class="ironmine-map"><span class="map5">
					#<strong>.</strong>
					#</span></div>
					#
					# or
					#
					#<div class="town-map"><a href="map.php"><span class="map5-town">
					#<u>Dr</u>
					#</span></a></div>
					
					# double check terrain
					# <span class="map7-town">
					regex.compile("<span class=\"map(\\d+)-?[a-z]*?\">")
					result = regex.search(td_contents)
					if result:
						#print("found a town on terrain " + result.get_string(1))
						found_identified = true
						# checkings for towns will find towns
						#_increment_counts("towns")
						_increment_counts("terrains")
						update_results()
						var td_terrain_id = int(result.get_string(1))
						if td_terrain_id != tile_details["terrain_id"]:
							print("Terrains don't match!!!")
							print("Map id: map-" + str(tile_details["map_id"]))
							print("tile map: " + str(tile_details["terrain_id"]))
							print("td contents: " + str(td_terrain_id))
							_increment_counts("warnings")
					
					# check for path
					# <strong>.</strong>
					regex.compile("<strong>.</?strong>")
					result = regex.search(td_contents)
					if result:
						#print("found a path")
						found_identified = true
						_increment_counts("paths")
						update_results()
					
					# check for characters
					# removing for now, it chatches too much and isn't needed for now
					# <span class="map7-town">ti</span>
					#regex.compile("<span class=\"map(\\d+)-?[a-z]*?\">[a-zA-Z\\s\\S]*?</?span>")
					#result = regex.search(td_contents)
					#if result:
						#print("found a character on terrain " + result.get_string(1))
						#found_identified = true
						#_increment_counts("characters")
						#_increment_counts("terrains")
						#update_results()
					
					# check for mine
					# <div class="ironmine-map">
					regex.compile("<div class=\"([a-zA-Z]*?)mine-map\">")
					result = regex.search(td_contents)
					if result:
						#print("found a " + result.get_string(1) + " mine")
						found_identified = true
						pending_mines.append({"type": MapDetailsSingleton.mine_string_to_mine_type.find(result.get_string(1)),
						"x": tile_details["location"].x,
						"y": tile_details["location"].y,
						"z": tile_details["location"].z})
						_increment_counts("mines")
						update_results()
					
					# check for town
					# <div class="town-map">
					regex.compile("<div class=\"town-map\">")
					result = regex.search(td_contents)
					if result:
						#print("found a town")
						found_identified = true
						pending_towns.append({"x": tile_details["location"].x,
						"y": tile_details["location"].y,
						"z": tile_details["location"].z})
						_increment_counts("towns")
						update_results()
					
					if not found_identified:
						print("td contents not identified: " + td_contents)
						_increment_counts("warnings")
						update_results()
				
				if MapDetailsSingleton.map_tiles.has(tile_details["location"]):
					if MapDetailsSingleton.map_tiles[tile_details["location"]].tile_image_id != tile_details["map_id"] || MapDetailsSingleton.map_tiles[tile_details["location"]].terrain_id != tile_details["terrain_id"]:
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
