extends Node

signal TimeOut
signal StartTurn
signal SpawnIngredient

var players : Dictionary[int, PlayerData] = {}
var ingredient_dictionary: Dictionary[int, ItemController] = {}

func add_ingredient_to_dictionary(ingredient : ItemController):
	var id = ingredient_dictionary.size()
	ingredient.id = id
	ingredient_dictionary.set(id, ingredient)

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
	for ingredient in ingredient_dictionary.keys():
		var random = randi_range(0, GlobalData.currentRecipe.ingredients.size()-1)
		random_list.append(random)
	set_items.rpc(random_list, recipe)

@rpc("authority", "call_local")
func end_turn():
	ingredient_dictionary.clear()
	SpawnIngredient.emit()
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		host_randomize_items()
	StartTurn.emit()

@rpc("any_peer", "call_local")
func set_items(random_list, recipe):
	GlobalData.setCurrentRecipe(recipe)
	for i in range(random_list.size()):
		var random = random_list[i]
		var ingredient = ingredient_dictionary[i]
		var ing : Ingredient = GlobalData.currentRecipe.ingredients[random]
		ingredient.ingredient_name = ing.ingredient_name
		ingredient.ingredient_type = ing.ingredient_type
		ingredient.set_model()

@rpc("any_peer", "call_local", "reliable")	
func consume_item(item_id, player_id):
	var item = ingredient_dictionary[item_id]
	players[player_id].current_inventory.append(item.ingredient_name)
	players[player_id].score += 5
	item.queue_free()
	
@rpc("any_peer", "call_local")
func print_stats():
	print("STATS para PLAYER %d" % multiplayer.get_unique_id())
	for player : PlayerData in players.values():
		print("		%s TEM O SEGUINTE INVENTARIO" % player.name)
		for item : String in player.current_inventory:
			print("		%s" % item)
		print("%s TEM O PLACAR DE %d" % [player.name, player.score])
