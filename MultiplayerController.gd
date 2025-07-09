extends Control
@export var IP_ADDRESS = "127.0.0.1"
@export var PORT = 8910
@export var MAX_PLAYERS = 4

var peer

func _ready() -> void:
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connection_failed.connect(connection_failed)
	multiplayer.connected_to_server.connect(connected_to_server)
	
# this gets called on the server and clients
func peer_connected(id):
	print("Player Connected ", id)

# this gets called on the server and clients	
func peer_disconnected(id):
	print("Player Disconnected ", id)

#called only from clients
func connected_to_server():
	print("Connected to Server")

#called only from clients	
func connection_failed():
	print("Couldn't Connect")

func _on_host_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_PLAYERS)
	if error != OK:
		print("nao rolo")
		return
	multiplayer.multiplayer_peer = peer
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	print("ghost host")

func _on_join_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	

func _on_start_pressed() -> void:
	print("start")
