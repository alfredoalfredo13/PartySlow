extends Control
@export var IP_ADDRESS = "127.0.0.1"
@export var PORT = 8910
@export var MAX_PLAYERS = 4
@export var player : PackedScene

var peer
var id : String
var is_host : bool = false
var local_player_data : PlayerData

func _ready() -> void:
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connection_failed.connect(connection_failed)
	multiplayer.connected_to_server.connect(connected_to_server)
	local_player_data = PlayerData.new()
	
# this gets called on the server and clients
func peer_connected(id):
	self.id = str(id)
	print("Player Connected ", id)

# this gets called on the server and clients	
func peer_disconnected(id):
	print("Player Disconnected ", id)

#called only from clients
func connected_to_server():
	print("Connected to Server.....")
	send_player_information.rpc_id(1, local_player_data.name, local_player_data.char_classe, multiplayer.get_unique_id())

#called only from clients	
func connection_failed():
	print("Couldn't Connect")

#Roda toda vez que um novo player conecta no servidor
@rpc("any_peer", "call_remote")
func send_player_information(name, character, id):
	print("is host = ", is_host)
	if !GameManager.players.has(id):
		var new_player = PlayerData.new()
		new_player.id = id
		new_player.name = name
		new_player.char_classe = character
		GameManager.players.set(id, new_player)
		
	print(id)
	if multiplayer.is_server():
		for i in GameManager.players:
			var player : PlayerData = GameManager.players[i]
			send_player_information.rpc(player.name, player.char_classe, player.id)

@rpc("any_peer", "call_local")
func start_game():
	$Host.visible = false
	$Join.visible = false
	$Start.visible = false
	$Label.visible = false
	$LineEdit.visible = false
	for i in GameManager.players:
		var player_instance :PlayerController = player.instantiate()
		var remote_player_data : PlayerData = GameManager.players[i]
		player_instance.player_data = remote_player_data
		player_instance.seta_name(remote_player_data.name)
		if i == 1:
			player_instance.position = Vector3(-2.0, 0.5, -2.0)
		else:
			player_instance.position = Vector3(2.0, 0.5, 2.0)
		get_tree().root.add_child(player_instance)

func _on_host_pressed() -> void:
	is_host = true
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_PLAYERS)
	if error != OK:
		print("nao rolo")
		return
	multiplayer.multiplayer_peer = peer
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	print("ghost host is waiting...")
	$Start.visible = true
	send_player_information(local_player_data.name, local_player_data.char_classe, multiplayer.get_unique_id())
	
func _on_join_pressed() -> void:
	is_host = false
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
func _on_start_pressed() -> void:
	for i in GameManager.players:
		print(i)
	start_game.rpc()
	print("start")

func _on_line_edit_text_submitted(new_text: String) -> void:
	local_player_data.name = new_text
	$Host.visible = true
	$Join.visible = true
