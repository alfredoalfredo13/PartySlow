extends Area3D
@export var ingredient_name : String = "Bun"
@export var ingredient_type : String = "Bread"

var model_node : Node3D

const MODEL_PATHS := {
	"Bun": preload("res://Restaurant_Bits/Assets/fbx/food_ingredient_bun.fbx"),
	"Lettuce": preload("res://Restaurant_Bits/Assets/fbx/food_ingredient_lettuce_slice.fbx"),
	"Cheese": preload("res://Restaurant_Bits/Assets/fbx/food_ingredient_cheese_slice.fbx"),
	"Burger": preload("res://Restaurant_Bits/Assets/fbx/food_ingredient_burger_cooked.fbx")
}

func _ready() -> void:
	$MeshInstance3D.visible = false
	while GlobalData.currentRecipe == null:
		await get_tree().create_timer(0.1).timeout
	var random = randi_range(0, GlobalData.currentRecipe.ingredients.size()-1)
	var ing : Ingredient = GlobalData.currentRecipe.ingredients[random]
	ingredient_name = ing.ingredient_name
	ingredient_type = ing.ingredient_type
	set_model(ingredient_name)

func set_model(iName : String) -> void : 
	if MODEL_PATHS.has(iName):
		var model_scene : PackedScene = MODEL_PATHS[iName]
		model_node = model_scene.instantiate()
		add_child(model_node)
		print("model instantiated: " + iName)
	else:
		print("model not found for ingredient " + iName)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Players"):
		body.inventory.append(ingredient_name)
		queue_free()
