class_name PlayerData extends Resource

enum Characters_Enum
{
	Barbaro, Mage, Knight, Rogue
}

@export var char_classe : Characters_Enum
@export var id : int
@export var name : String
var in_game = false

signal remove_player
