extends Control

@export var host_game_button: Button
@export var join_game_button: Button
@export var ip_menu : Control
@export var noray_menu : Control
@export var lobby : Control
@export var connection_type : RichTextLabel

var _is_hosting = false

func _ready():
	print("Main menu ready...")
	GameManager.GameStart.connect(hide)
	GameManager.secondary_menu_completed.connect(_secondary_menu_submitted)
	GameManager.lobby_show.connect(lobby.show)
	GameManager.secondary_menu_cancelled.connect(_cancel_secondary_menu)
	GameManager.secondary_menu_cancelled.connect(lobby.hide)
	if GameManager.multiplayer_mode == GameManager.MultiplayerMode.Noray:
		connection_type.text = "Connection Mode: SERVER"
	else:
		connection_type.text = "Connection Mode: P2P"
	if OS.has_feature(NetworkManager.DEDICATED_SERVER_FEATURE_NAME):
		print("Calling host game for dedicated server setup...")
		NetworkManager.host_game(NetworkConnectionConfigs.new(NetworkManager.LOCALHOST))

func host_game():
	if (GameManager.multiplayer_mode == GameManager.MultiplayerMode.Direct):
		ip_menu.shows(true)
		return
	print("Host game pressed")
	_is_hosting = true

	# Has a secondary network option been selected for host
	if NetworkManager.selected_network != NetworkManager.AvailableNetworks.ENET:
		_show_secondary_network_options(true)
	else:
		NetworkManager.host_game(NetworkConnectionConfigs.new(NetworkManager.LOCALHOST))

func join_game():
	if (GameManager.multiplayer_mode == GameManager.MultiplayerMode.Direct):
		ip_menu.shows(false)
		return
	_show_secondary_network_options()

func _show_secondary_network_options(is_hosting: bool = false):
	_hide_main_menu_options()
	noray_menu.go_button.visible = true
	# Add whatever necessary configuration is required in the sub menu
	if _is_hosting:
		print("IS HOSTING")
		noray_menu.menu_config_options = { "is_hosting": is_hosting }
	noray_menu.shows(is_hosting)
	noray_menu.visible = true

func _secondary_menu_submitted(network_connection_configs: NetworkConnectionConfigs):
	if _is_hosting:
		NetworkManager.host_game(network_connection_configs)
	else:
		NetworkManager.join_game(network_connection_configs)

func _reset_main_menu_options():
	_is_hosting = false
	host_game_button.visible = true
	join_game_button.visible = true

func _hide_main_menu_options():
	host_game_button.visible = false
	join_game_button.visible = false


func _cancel_secondary_menu():
	_reset_main_menu_options()
	# Remove secondary menu
	noray_menu.visible = false

func _on_secondary_toggle_toggled(noray_enabled):
	print("Noray enabled %s" % noray_enabled)
	if noray_enabled:
		NetworkManager.set_selected_network(NetworkManager.AvailableNetworks.NORAY)
	else:
		NetworkManager.set_selected_network(NetworkManager.AvailableNetworks.ENET)

func exit_game():
	get_tree().quit(0)

func _on_change_connection_mode():
	GameManager.clear()
