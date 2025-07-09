extends Node3D

var random : int
var recipe : String

func _ready() -> void:
	for recipe in GlobalData.recipes:
		print(recipe.recipe_name)
	random = randi_range(0, GlobalData.recipes.size()-1)
	print("random = " + str(random))
	GlobalData.currentRecipe = GlobalData.recipes[random]
	print("current recipe: " + GlobalData.currentRecipe.recipe_name)
