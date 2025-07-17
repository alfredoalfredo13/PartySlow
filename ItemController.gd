class_name ItemController extends Area3D
@export var ingredient_name : String = "Bun"
@export var ingredient_type : String = "Bread"
var id : int

var model_node : MeshInstance3D

const MODEL_PATHS := {
	"Bun": preload("res://Restaurant_Bits/Assets/obj/food_ingredient_bun.obj"),
	"Lettuce": preload("res://Restaurant_Bits/Assets/obj/food_ingredient_lettuce_slice.obj"),
	"Cheese": preload("res://Restaurant_Bits/Assets/obj/food_ingredient_cheese_slice.obj"),
	"Burger": preload("res://Restaurant_Bits/Assets/obj/food_ingredient_burger_cooked.obj"),
	"Potato":preload("res://Restaurant_Bits/Assets/obj/food_ingredient_potato_chopped.obj"),
	"Onion":preload("res://Restaurant_Bits/Assets/obj/food_ingredient_onion_chopped.obj"),
	"Carrot":preload("res://Restaurant_Bits/Assets/obj/food_ingredient_carrot.obj"),
	"Chicken":preload("res://Restaurant_Bits/Assets/obj/food_ingredient_ham.obj"),
	"Tomato":preload("res://Restaurant_Bits/Assets/obj/food_ingredient_tomato.obj")
}

func _ready() -> void:
	GameManager.add_ingredient_to_list(self)
	

func set_model() -> void : 
	print(ingredient_type, " ", ingredient_name)
	if MODEL_PATHS.has(ingredient_name):
		var model : Mesh = MODEL_PATHS[ingredient_name]
		$MeshInstance3D.mesh = model
		#print("model instantiated: " + iName)
	else:
		print("model not found for ingredient " + ingredient_name)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Players"):
		GameManager.consume_item.rpc(id, body.player_data.id)
