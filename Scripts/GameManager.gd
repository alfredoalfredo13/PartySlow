extends Node

enum MultiplayerMode {Noray, Direct}

var multiplayer_mode : MultiplayerMode = MultiplayerMode.Direct

signal TimeOut
signal StartTurn
signal SpawnIngredient
signal GameStart

signal secondary_menu_completed
signal secondary_menu_cancelled
signal lobby_show
signal lobby_hide

signal SetRecipeUI(recipe : Recipe)
signal AddIngredientToInventory(count, name)
signal AddScore(score)

var current_turn = 0
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
	
func authority_end_turn():
	if multiplayer.get_unique_id() != get_multiplayer_authority():
		return
	if current_turn == 2:
		authority_end_game.rpc()
	else:
		end_turn.rpc()

@rpc("authority", "call_local", "reliable")
func authority_end_game():
	get_tree().change_scene_to_file("res://end_screen.tscn")

@rpc("authority", "call_local", "reliable")
func end_turn():
	ingredient_dictionary.clear()
	StartTurn.emit()
	for player : PlayerData in players.values():
		player.current_inventory.clear()
	SpawnIngredient.emit()
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		host_randomize_items()
	current_turn += 1

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
	if item == null:
		return
	var player = players[player_id]
	player.current_inventory.append(item.ingredient_name)
	#player.score += 5
	item.position = Vector3.FORWARD * 100000
	if player.is_local:
		var count = player.current_inventory.count(item.ingredient_name)
		AddIngredientToInventory.emit(count, item.ingredient_name)

@rpc("any_peer", "call_local")
func set_score(player_id, score):
	var player = players[player_id]
	player.score = score
	if player.is_local:
		AddScore.emit(score)

@rpc("any_peer", "call_remote", "reliable")
func send_player_information(player_name, character, id : int):
	var is_host = multiplayer.is_server()
	print("I AM %s : I RECEIVED %s is host = " % [multiplayer.get_unique_id(), id], is_host)
	if !players.has(id):
		var new_player = PlayerData.new()
		new_player.id = id
		new_player.name = player_name
		new_player.char_classe = character
		new_player.is_host = is_host
		players.set(id, new_player)
		# Remote names on the host wait for the client to acknowledge the roster.
		if not is_host or id == multiplayer.get_unique_id():
			NetworkManager.add_to_lobby.emit(player_name, id)
	if multiplayer.is_server():
		for i in players:
			var player : PlayerData = players[i]
			send_player_information.rpc(player.name, player.char_classe, player.id)
		# This marker follows the roster on the same reliable channel.
		var sender_id = multiplayer.get_remote_sender_id()
		if sender_id > 1:
			request_registration_confirmation.rpc_id(sender_id)

@rpc("authority", "call_remote", "reliable")
func request_registration_confirmation():
	confirm_registration.rpc_id(1)

@rpc("any_peer", "call_remote", "reliable")
func confirm_registration():
	if not multiplayer.is_server():
		return
	var sender_id = multiplayer.get_remote_sender_id()
	if players.has(sender_id):
		var player: PlayerData = players[sender_id]
		NetworkManager.add_to_lobby.emit(player.name, sender_id)

@rpc("authority", "call_local", "reliable")
func start_game():
	multiplayer.multiplayer_peer.refuse_new_connections = true
	GameStart.emit()
	var index = 0
	for i in players:
		var remote_player_data : PlayerData = players[i]
		if remote_player_data.in_game:
			continue
		remote_player_data.in_game = true
		var player_instance :PlayerController = preload("res://Scenes/Player.tscn").instantiate()
		player_instance.player_data = remote_player_data
		if remote_player_data.id == multiplayer.get_unique_id():
			set_mesh_layer_recursive(player_instance, 15, true)
			remote_player_data.is_local = true
		player_instance.seta_name(remote_player_data.name)
		var spawn_pos = (get_tree().get_nodes_in_group("PlayerSpawn")[index] as Node3D).global_position
		remote_player_data.spawn_point = Vector3(spawn_pos.x, 0.5, spawn_pos.z)
		player_instance.position = remote_player_data.spawn_point
		get_tree().root.add_child(player_instance)
		index += 1
	if multiplayer.is_server():
		host_randomize_items()
	StartTurn.emit()
	
@rpc("any_peer", "call_local")
func print_stats():
	print("STATS para PLAYER %d" % multiplayer.get_unique_id())
	for player : PlayerData in players.values():
		print("		%s TEM O SEGUINTE INVENTARIO" % player.name)
		for item : String in player.current_inventory:
			print("		%s" % item)
		print("%s		TEM O PLACAR DE %d" % [player.name, player.score])

# Keep the current scene and its ingredients available when leaving a lobby.
func reset_session():
	NetworkManager.disconnect_from_game()
	for player: PlayerData in players.values():
		player.remove_player.emit()
	players.clear()
	current_turn = 0

func clear():
	reset_session()
	ingredient_dictionary.clear()
	get_tree().change_scene_to_file("res://initial_screen.tscn")
