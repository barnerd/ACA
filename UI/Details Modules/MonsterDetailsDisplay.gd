extends HBoxContainer


func update(_monster) -> void:
	$"Id Label".text = str(_monster.monster_id)
	$"Name Label".text = _monster.monster_name
	$"Sorcery Label".text = str(_monster.sorcery_requirement)
	$"Health Label".text = str(_monster.monster_health)
