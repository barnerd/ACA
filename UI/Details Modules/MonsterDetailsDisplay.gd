extends HBoxContainer


func update(_monster) -> void:
	$"Id Label".text = str(_monster.id)
	$"Name Label".text = _monster.monster_name
	$"Sorcery Label".text = str(_monster.sorcery_req)
	$"Health Label".text = str(_monster.health)
