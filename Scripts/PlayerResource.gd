class_name PlayerData extends Resource

enum Characters_Enum
{
	Barbaro, Mage, Knight, Rogue
}

@export var char_classe : Characters_Enum
@export var id : int
@export var name : String
@export var is_local : bool
var is_host : bool = false
var spawn_point : Vector3
var completed_recipes : int = 0
var total_inventory : Array[String]
var current_inventory : Array[String]
var in_game = false
var score : int = 0

signal remove_player
