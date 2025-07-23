extends Area3D

func _on_body_entered(body: Node3D) -> void:
	#print(body.get_groups())
	if not body.is_in_group("Players"): 
		return
	var player_data :PlayerData = body.player_data
	if !player_data.is_local:
		return
	var ingredients = player_data.current_inventory.size()
	print()
	var points = ingredients + ((player_data.completed_recipes) * GlobalData.currentRecipe.ingredients.size()*2)
	player_data.score += points
	player_data.total_inventory.append_array(player_data.current_inventory)
	player_data.current_inventory.clear()
	GameManager.AddIngredientToInventory.emit(-1, "")
	GameManager.set_score.rpc(player_data.id, player_data.score)
