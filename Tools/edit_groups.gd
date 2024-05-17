extends Window

@onready var grid_parent = $PanelContainer/MarginContainer/ScrollContainer/VBoxContainer/GridContainer


func _on_visibility_changed() -> void:
	var new_label
	
	# clear out previous list of groups
	for child in grid_parent.get_children():
		child.queue_free()
	
	# add headers
	new_label = Label.new()
	new_label.text = "ID"
	new_label.theme_type_variation = &"HeaderLabel"
	grid_parent.add_child(new_label)
	
	new_label = Label.new()
	new_label.text = "Group"
	new_label.theme_type_variation = &"HeaderLabel"
	grid_parent.add_child(new_label)
	
	new_label = Label.new()
	new_label.text = "Faction"
	new_label.theme_type_variation = &"HeaderLabel"
	grid_parent.add_child(new_label)
	
	
	# add list of groups/towns
	for group in AgoniaData.MapData.groups_by_id.values():
		# group id
		new_label = Label.new()
		new_label.text = str(group.group_id)
		new_label.custom_minimum_size.x = 50
		grid_parent.add_child(new_label)
		
		# group name
		new_label = TextEdit.new()
		new_label.text = group.group_name
		new_label.custom_minimum_size.x = 365
		grid_parent.add_child(new_label)
		
		# group faction
		new_label = OptionButton.new()
		for faction in GroupDetails.Factions.values():
			new_label.add_item(GroupDetails.Faction_Names[faction], faction)
		new_label.select(new_label.get_item_index(group.group_faction))
		grid_parent.add_child(new_label)


func _on_add_pressed() -> void:
	var new_label
	# group id
	new_label = TextEdit.new()
	new_label.text = "id"
	new_label.custom_minimum_size.x = 50
	grid_parent.add_child(new_label)
	
	# group name
	new_label = TextEdit.new()
	new_label.text = "name"
	new_label.custom_minimum_size.x = 365
	grid_parent.add_child(new_label)
	
	# group faction
	new_label = OptionButton.new()
	for faction in GroupDetails.Factions.values():
		new_label.add_item(GroupDetails.Faction_Names[faction], faction)
	grid_parent.add_child(new_label)


func _on_update_pressed() -> void:
	var children = grid_parent.get_children()
	for child in range(0, children.size(), grid_parent.columns):
		if children[child].theme_type_variation != &"HeaderLabel":
			var group_id = children[child].text
			var group_name = children[child+1].text
			var group_faction = children[child+2].selected
			
			AgoniaData.MapData.update_group(int(group_id), group_name, group_faction)
