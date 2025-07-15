extends Area3D

func _on_body_entered(body: Node3D) -> void:
	#print(body.get_groups())
	if not body.is_in_group("Players"): return
	var ingredients = body.inventory.size()
	var completed = body.completed_recipes
	var points = ingredients + (completed*GlobalData.currentRecipe.ingredients.size()*2)
	body.points += points
	body.inventory.clear()
	body.completed_recipes = 0
