class_name PlayerData extends Resource

enum Characters_Enum
{
	Barbaro, Mage, Knight, Rogue
}

@export var char_classe : Characters_Enum
@export var id : int
@export var name : String
@export var is_local : bool
var inventory : Array[String]
var in_game = false
var score : int = 0

signal remove_player
