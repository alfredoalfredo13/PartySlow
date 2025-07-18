extends Area3D

func _on_body_entered(body: Node3D) -> void:
	#print(body.get_groups())
	if not body.is_in_group("Players"): return
	var player_data :PlayerData = body.player_data
	var ingredients = player_data.current_inventory.size()
	
	var points = ingredients + ((player_data.completed_recipes + 1)* GlobalData.currentRecipe.ingredients.size()*2)
	player_data += points
