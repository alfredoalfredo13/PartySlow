class_name PlayerData extends Resource

enum Characters_Enum
{
	Barbaro, Mage, Knight, Rogue
}

@export var char_classe : Characters_Enum
@export var id : int
@export var name : String

signal remove_player
