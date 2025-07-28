@tool
extends Control

@onready var names : Dictionary[String, Label] = {
	"R1" : $R1/Player/PanelContainer/Player,
	"R2" : $R2/Player/PanelContainer/Player,
	"R3" : $R3/Player/PanelContainer/Player,
	"R4" : $R4/Player/PanelContainer/Player
}

@onready var scores : Dictionary[String, Label] = {
	"R1" : $R1/Score/PanelContainer/Score,
	"R2" : $R2/Score/PanelContainer/Score,
	"R3" : $R3/Score/PanelContainer/Score,
	"R4" : $R4/Score/PanelContainer/Score
}

@onready var places : Dictionary[String, Label] = {
	"R1" : $R1/Place/PanelContainer/Place,
	"R2" : $R2/Place/PanelContainer/Place,
	"R3" : $R3/Place/PanelContainer/Place,
	"R4" : $R4/Place/PanelContainer/Place
}
@onready var rows : Dictionary[String, Control] = {
	"R1" : $R1,
	"R2" : $R2,
	"R3" : $R3,
	"R4" : $R4
}
var random_names : Array[String] = ["Harry", "Jonas", "Sonic", "Serjev", "Dontatello"]
var players_list : Array[PlayerData] = []

@export var new_color : Color:
	get:
		return new_color
	set(value):
		print(value)
		new_color = value
		_call_my_function(self, new_color)

func set_maximum_range(value):
	new_color = value

@export_tool_button("Set", "Callable")
var color_button = _call_my_function.bind(self, new_color)

@export_tool_button("RandomScore", "Callable")
var random_button = _random

func _ready() -> void:
	players_list = GameManager.players.values()
	players_list.sort_custom(func(a : PlayerData, b : PlayerData):
		return a.score > b.score	
	)
	var row_keys : Array[String] = ["R1", "R2", "R3", "R4"]
	for i in range(rows.size() - 1, -1, -1):
		print(i, " bigger than ", players_list.size(), " ", i > players_list.size())
		if i >= players_list.size():
			rows[row_keys[i]].hide()
	var i = 0
	for player in players_list: 
		var key = row_keys[i]
		names[key].text = player.name
		scores[key].text = str(player.score)
		i += 1
		
func _random():
	var scores_values : Array[Rank] = []
	for score_key in scores.keys():
		var rand_val = randi()%500
		scores_values.append(Rank.new(rand_val, score_key))
		scores_values.sort_custom(func(a : Rank, b : Rank): 
			return a.score > b.score
		)
		for value : Rank in scores_values:
			print("		%s" % value.to_string())
		print(scores_values[0].to_string())
		scores[score_key].text = str(rand_val)
	for name in names.values():
		name.text = random_names[randi() % random_names.size()]
	
	scores_values[0].place = 1
	for i in range(1, scores_values.size()):
		var value = scores_values[i]
		var prev = scores_values[i - 1]
		if value.score == prev.score:
			value.place = prev.place
		else:
			value.place = i + 1
				
	for i in range(scores_values.size()):
		var rank = scores_values[i]
		print("rank %d %s" % [rank.place, rank.label_key])
		var place : String = ""
		if rank.place == 1:
			place = "1st"
			print(place)
		elif rank.place == 2:
			place = "2nd"
			print(place)
		elif rank.place == 3:
			place = "3rd"
			print(place)
		else:
			place = "4th"
			print(place)
		places[rank.label_key].text = place
		
func _call_my_function(node : Node, new_color):
	if node is ColorRect:
		(node as ColorRect).color = new_color
	for child in node.get_children(true):
		_call_my_function(child, new_color)

func _on_button_2_pressed() -> void:
	NetworkManager.disconnect_from_game()
	get_tree().change_scene_to_file("res://Main.tscn")

class Rank:
	var score : int
	var label_key : String
	var place : int = 1
	
	func _init(score, label_key) -> void:
		self.score = score
		self.label_key = label_key
		
	func _to_string() -> String:
		return "key : %s pos : %d" % [label_key, place]
	
