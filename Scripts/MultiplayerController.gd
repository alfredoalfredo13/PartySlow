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
	local_player_data = PlayerData.new()
	local_player_data.name = name
	
# this gets called on the server and clients
func peer_connected(id):
	self.id = str(id)
	if id == get_multiplayer_authority():
		is_host = true
	print("Player Connected ", id)

# this gets called on the server and clients	
func peer_disconnected(id):
#	if !GameManager.players.keys().has(id):
#		print("HOST SERVER DISCONNECTED")
#		return
	var player_data : PlayerData = GameManager.players[id]
	if player_data.is_host:
		print("HOST PLAYER DISCONNECTED")
	GameManager.players.erase(id)
	player_data.remove_player.emit()
	NetworkManager.remove_from_lobby.emit(id)
	print("Player Disconnected ", id)

#called only from clients
func connected_to_server():
	GameManager.players.clear()
	print("Client %d Connected to Server" % multiplayer.get_unique_id())
	GameManager.send_player_information.rpc_id(1, NetworkManager.name_tag, local_player_data.char_classe, multiplayer.get_unique_id())

#called only from clients	
func connection_failed():
	print("Server is Down")
	pass

func _on_line_edit_text_submitted(new_text: String) -> void:
	local_player_data.name = new_text
	#$Host.visible = true
	#$Join.visible = true
