extends VBoxContainer
@export var ip_line : LineEdit
@export var name_line : LineEdit
@onready var start : Button = $BoxContainer/Start
@onready var go : Button = $BoxContainer/Go
@onready var back : Button = $BoxContainer/Back

@export var IP_ADDRESS = "127.0.0.1"
@export var PORT = 8910
@export var MAX_PLAYERS = 4

var peer
var is_host : bool = false

func host_game():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_PLAYERS)
	if error != OK:
		print("nao rolo")
		return
	multiplayer.multiplayer_peer = peer
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	GameManager.send_player_information(name_line.text, PlayerData.Characters_Enum.Barbaro, multiplayer.get_unique_id())
	start.show()
	go.hide()
	
	print("ghost host is waiting...")
	
func join_game() -> void:
	NetworkManager.name_tag = name_line.text
	go.hide()
	is_host = false
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip_line.text, PORT)
	multiplayer.multiplayer_peer = peer
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)

func shows(is_host):
	self.is_host = is_host
	ip_line.visible = !is_host
	name_line.visible = true
	go.show()
	back.show()
	start.hide()
	show()
	
func _on_back_pressed() -> void:
	multiplayer.multiplayer_peer = null
	ip_line.hide()
	name_line.hide()
	go.hide()
	back.hide()
	start.hide()
	hide()

func _on_go_pressed() -> void:
	if name_line.text.is_empty():
		return
	if is_host:
		host_game()
	else:
		if !ip_line.text.is_empty():
			join_game()

func _on_start_pressed() -> void:
	GameManager.start_game.rpc()
