extends Control

const NORAY_CLIENT_PLACEHOLDER_TEXT = "Enter Host's Game ID"
const NORAY_HOSTING_LABEL = "Host Game with Noray!"
const NORAY_CLIENT_CONNECT_LABEL = "Connect to game on Noray!"

@export var go_button: Button
@export var back_button: Button
@export var start_button : Button
@export var name_input: LineEdit
@export var host_gameid_input: LineEdit
@onready var copy_label = $CopyTheCode
@onready var failed_to_connect = $FailedToConnect

var menu_config_options: Dictionary = {}
var _is_hosting: bool = false

func _ready():
	host_gameid_input.placeholder_text = NORAY_CLIENT_PLACEHOLDER_TEXT
	host_gameid_input.text = ""
	NetworkManager.failed_to_connect.connect(failed_to_connect.show)
	
		
func shows(is_host : bool):
	_is_hosting = is_host
	if _is_hosting:
		host_gameid_input.visible = false
	else:
		host_gameid_input.visible = true  
	name_input.show()  

func _on_go_pressed():
	if name_input.text.is_empty():
		return
	print(name_input.text)
	if _is_hosting:
		# Noray Host IP is required to host game
		if name_input.text && name_input.text != "":
			NetworkManager.set_name_tag(name_input.text)
			var network_connection_configs = NetworkConnectionConfigs.new("foxssake.studio")
			GameManager.secondary_menu_completed.emit(network_connection_configs)
			await Noray.on_oid
			GameManager.lobby_show.emit()
			host_gameid_input.text = Noray.oid
			host_gameid_input.editable = false
			copy_label.show()
			host_gameid_input.visible = true
			start_button.visible = true
			go_button.visible = false
	else:
		# Host IP AND Game ID required to join Noray as client
		if name_input.text && name_input.text != "" && host_gameid_input.text && host_gameid_input.text != "":
			NetworkManager.set_name_tag(name_input.text)
			var network_connection_configs = NetworkConnectionConfigs.new("foxssake.studio")
			network_connection_configs.game_id = host_gameid_input.text
			GameManager.secondary_menu_completed.emit(network_connection_configs)
			GameManager.lobby_show.emit()
			go_button.visible = false

func _on_back_pressed():
	print("On back pressed")
	host_gameid_input.text = ""
	host_gameid_input.editable = true
	GameManager.reset_session()
	start_button.visible = false
	copy_label.hide()
	failed_to_connect.hide()
	GameManager.secondary_menu_cancelled.emit()
	GameManager.lobby_hide.emit()

func _on_start_pressed() -> void:
	if multiplayer.is_server():
		GameManager.start_game.rpc()
