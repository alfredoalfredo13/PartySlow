extends Control

func set_p2p():
	GameManager.multiplayer_mode = GameManager.MultiplayerMode.Direct
	get_tree().change_scene_to_file("res://Main.tscn")
	
func set_noray():
	GameManager.multiplayer_mode = GameManager.MultiplayerMode.Noray
	get_tree().change_scene_to_file("res://Main.tscn")
	
	
	
