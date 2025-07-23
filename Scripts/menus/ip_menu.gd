extends VBoxContainer
@export var ip_line : LineEdit
@export var name_line : LineEdit

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
	if (GameManager.multiplayer_mode == GameManager.MultiplayerMode.Noray):
		return
	host_game()	
	#$Start.visible = true
	GameManager.send_player_information(NetworkManager.name_tag, local_player_data.char_classe, multiplayer.get_unique_id())
	
func _on_join_pressed() -> void:
	if (GameManager.multiplayer_mode == GameManager.MultiplayerMode.Noray):
		return
	is_host = false
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
