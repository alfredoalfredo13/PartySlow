@tool
extends Control

@onready var first_place : Dictionary[String, Label] = {
	"Name" : $HBoxContainer/FirstPlace/Label3,
	"Score" : $HBoxContainer/FirstPlace/Label2
}

@onready var second_place : Dictionary[String, Label] = {
	"Name" : $HBoxContainer/SecondPlace/Label3,
	"Score" : $HBoxContainer/SecondPlace/Label2
}

@onready var third_place : Dictionary[String, Label] = {
	"Name" : $HBoxContainer/ThirdPlace/Label3,
	"Score" : $HBoxContainer/ThirdPlace/Label2
}

@onready var last_place : Dictionary[String, Label] = {
	"Name" : $HBoxContainer/LastPlace/Label3,
	"Score" : $HBoxContainer/LastPlace/Label2
}

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

func _random():
	var dictionary_list : Array[Dictionary] = [first_place, second_place, third_place, last_place]
	for d in dictionary_list:
		d["Name"].text = str((randi()%9999) + 10000) + "       "
		d["Score"].text = str(randi()%500)

func _call_my_function(node : Node, new_color):
	if node is ColorRect:
		(node as ColorRect).color = new_color
	for child in node.get_children(true):
		_call_my_function(child, new_color)
