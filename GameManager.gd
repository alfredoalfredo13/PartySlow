extends Node

var players : Dictionary = {}
var ingredients: Array[ItemController] = []

func set_mesh_layer_recursive(node: Node, layer: int, visible : bool):
	if node is VisualInstance3D:
			var mesh = node as VisualInstance3D
			mesh.set_layer_mask_value(layer, visible)
	for child in node.get_children():
		set_mesh_layer_recursive(child, layer, visible)

func host_randomize_items():
	var recipe = randi_range(0, GlobalData.recipes.size()-1)
	GlobalData.setCurrentRecipe(recipe)
	var random_list = []
	print("selecting items...")
	for ingredient in ingredients:
		var random = randi_range(0, GlobalData.currentRecipe.ingredients.size()-1)
		random_list.append(random)
	set_items.rpc(random_list, recipe)

@rpc("any_peer", "call_local")
func set_items(random_list, recipe):
	GlobalData.setCurrentRecipe(recipe)
	for i in range(random_list.size()):
		var random = random_list[i]
		var ingredient = ingredients[i]
		var ing : Ingredient = GlobalData.currentRecipe.ingredients[random]
		ingredient.ingredient_name = ing.ingredient_name
		ingredient.ingredient_type = ing.ingredient_type
		print("%d: %d - %s" % [i, random, ing.ingredient_name])
		ingredient.set_model()
	
	

@rpc("any_peer", "call_local", "reliable")	
func synchronize_ingredients():
	pass
