extends Control

signal secondary_menu_completed
signal secondary_menu_cancelled

const NORAY_CLIENT_PLACEHOLDER_TEXT = "Enter Host's Game ID"
const NORAY_HOSTING_LABEL = "Host Game with Noray!"
const NORAY_CLIENT_CONNECT_LABEL = "Connect to game on Noray!"

@export var go_button: Button
@export var back_button: Button
@export var start_button : Button
@export var name_input: LineEdit
@export var host_gameid_input: LineEdit

var menu_config_options: Dictionary = {}
var _is_hosting: bool = false

func _ready():
	host_gameid_input.placeholder_text = NORAY_CLIENT_PLACEHOLDER_TEXT
	host_gameid_input.text = ""
		
func shows(is_host : bool):
	_is_hosting = is_host
	if _is_hosting:
		host_gameid_input.visible = false
	else:
		host_gameid_input.visible = true  
	name_input.show()  

func _on_go_pressed():
	print("On Noray go presssed")
	if _is_hosting:
		# Noray Host IP is required to host game
		if name_input.text && name_input.text != "":
			NetworkManager.set_name_tag(name_input.text)
			var network_connection_configs = NetworkConnectionConfigs.new("159.89.81.45")
			secondary_menu_completed.emit(network_connection_configs)
			await  Noray.on_oid
			host_gameid_input.text = Noray.oid
			host_gameid_input.visible = true
			
			start_button.visible = true
			go_button.visible = false
	else:
		# Host IP AND Game ID required to join Noray as client
		if name_input.text && name_input.text != "" && host_gameid_input.text && host_gameid_input.text != "":
			NetworkManager.set_name_tag(name_input.text)
			var network_connection_configs = NetworkConnectionConfigs.new("159.89.81.45")
			network_connection_configs.game_id = host_gameid_input.text
			secondary_menu_completed.emit(network_connection_configs)
			go_button.visible = false

func _on_back_pressed():
	print("On back pressed")
	NetworkManager.disconnect_from_game()
	start_button.visible = false
	secondary_menu_cancelled.emit()

func _on_start_pressed() -> void:
	if multiplayer.is_server():
		GameManager.start_game.rpc()
