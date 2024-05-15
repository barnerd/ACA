extends Window

@onready var grid_parent = $PanelContainer/MarginContainer/ScrollContainer/GridContainer


func _on_visibility_changed() -> void:
	var new_label
	
	# clear out previous list of groups
	for child in grid_parent.get_children():
		child.queue_free()
	
	# add headers
	new_label = Label.new()
	new_label.text = "Group"
	new_label.theme_type_variation = &"HeaderLabel"
	grid_parent.add_child(new_label)
	
	new_label = Label.new()
	new_label.text = "Faction"
	new_label.theme_type_variation = &"HeaderLabel"
	grid_parent.add_child(new_label)
	
	new_label = Label.new()
	new_label.text = "Town"
	new_label.theme_type_variation = &"HeaderLabel"
	grid_parent.add_child(new_label)
	
	new_label = Label.new()
	new_label.text = "Coords"
	new_label.theme_type_variation = &"HeaderLabel"
	grid_parent.add_child(new_label)
	
	# add list of groups/towns
	for group in AgoniaData.MapData.groups_by_id.values():
		# group name
		new_label = Label.new()
		new_label.text = group.group_name
		grid_parent.add_child(new_label)
		
		# group faction
		new_label = Label.new()
		new_label.text = GroupDetails.Faction_Names[group.group_faction]
		grid_parent.add_child(new_label)
		
		if group.towns.size() == 1:
			# town name
			new_label = Label.new()
			new_label.text = group.towns[0].town_name
			grid_parent.add_child(new_label)
			
			# town coords
			new_label = Label.new()
			new_label.text = "%d,%d" % [group.towns[0].location.x, group.towns[0].location.y]
			grid_parent.add_child(new_label)
		elif group.towns.size() > 0:
			print("%s group has %d towns" % [group.group_name, group.towns.count])
		else:
			# empty town name
			new_label = Label.new()
			new_label.text = ""
			grid_parent.add_child(new_label)
			
			# empty town coords
			new_label = Label.new()
			new_label.text = ""
			grid_parent.add_child(new_label)
