extends Node
@export var IP_ADDRESS = "127.0.0.1"
@export var PORT = 8910
@export var MAX_PLAYERS = 4
@export var player : PackedScene
@export var menu : Control

var peer
var id : String
var is_host : bool = false
var local_player_data : PlayerData
var has_started = false

func _ready() -> void:
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connection_failed.connect(connection_failed)
	multiplayer.connected_to_server.connect(connected_to_server)
	NetworkManager.set_host.connect(_on_host_pressed)
	local_player_data = PlayerData.new()
	if "--server" in OS.get_cmdline_args() or OS.has_feature("dedicated_server"):
		#$Host.visible = false
		#$Join.visible = false
		#$Start.visible = false
		#$Label.visible = false
		#$LineEdit.visible = false
		#host_game()
		pass
	else:
		if OS.get_cmdline_args().size() > 0:
			var name = OS.get_cmdline_args()[1]
		#$LineEdit.text = name
		local_player_data.name = name
	
# this gets called on the server and clients
func peer_connected(id):
	self.id = str(id)
	if id == get_multiplayer_authority():
		is_host = true
	print("Player Connected ", id)

# this gets called on the server and clients	
func peer_disconnected(id):
	if !GameManager.players.keys().has(id):
		print("HOST SERVER DISCONNECTED")
		return
	var player_data : PlayerData = GameManager.players[id]
	if player_data.is_host:
		print("HOST PLAYER DISCONNECTED")
	GameManager.players.erase(id)
	player_data.remove_player.emit()
	print("Player Disconnected ", id)

#called only from clients
func connected_to_server():
	print("Client %d Connected to Server" % multiplayer.get_unique_id())
	send_player_information.rpc_id(1, local_player_data.name, local_player_data.char_classe, multiplayer.get_unique_id())

#called only from clients	
func connection_failed():
	print("Server is Down")
	pass

#Roda toda vez que um novo player conecta no servidor
@rpc("any_peer", "call_remote")
func send_player_information(name, character, id):
	is_host = multiplayer.is_server()
	print("I AM %s : I RECEIVED %s is host = " % [multiplayer.get_unique_id(), id], is_host)
	if !GameManager.players.has(id):
		var new_player = PlayerData.new()
		new_player.id = id
		new_player.name = name
		new_player.char_classe = character
		new_player.is_host = is_host
		GameManager.players.set(id, new_player)
	if multiplayer.is_server():
		for i in GameManager.players:
			var player : PlayerData = GameManager.players[i]
			send_player_information.rpc(player.name, player.char_classe, player.id)

@rpc("any_peer", "call_local")
func start_game():
	print("Game Starting for Player %s" % id)
	menu.visible = false
	#$Host.visible = false
	#$Join.visible = false
	#$Start.visible = false
	#$Label.visible = false
	#$LineEdit.visible = false
	var index = 0
	var local : PlayerController
	print(GameManager.players.keys().size())
	for i in GameManager.players:
		var remote_player_data : PlayerData = GameManager.players[i]
		if remote_player_data.in_game:
			continue
		remote_player_data.in_game = true
		
		var player_instance :PlayerController = player.instantiate()
		player_instance.player_data = remote_player_data
		
		if remote_player_data.id == multiplayer.get_unique_id():
			local = player_instance
			GameManager.set_mesh_layer_recursive(player_instance, 15, true)
			remote_player_data.is_local = true
		player_instance.seta_name(remote_player_data.name)
		var spawn_pos = (get_tree().get_nodes_in_group("PlayerSpawn")[index] as Node3D).global_position
		remote_player_data.spawn_point = Vector3(spawn_pos.x, 0.5, spawn_pos.z)
		player_instance.position = remote_player_data.spawn_point
		get_tree().root.add_child(player_instance)
		index += 1
	if is_host:
		GameManager.host_randomize_items()
		GameManager.StartTurn.emit()
		
func host_game():
	is_host = true
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_PLAYERS)
	if error != OK:
		#print("nao rolo")
		return
	multiplayer.multiplayer_peer = peer
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	#print("ghost host is waiting...")

func _on_host_pressed() -> void:
	#host_game()	
	#$Start.visible = true
	send_player_information(local_player_data.name, local_player_data.char_classe, multiplayer.get_unique_id())
	
func _on_join_pressed() -> void:
	is_host = false
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
func _on_start_pressed() -> void:
	start_game.rpc()
	#print("start")

func _on_line_edit_text_submitted(new_text: String) -> void:
	local_player_data.name = new_text
	#$Host.visible = true
	#$Join.visible = true
