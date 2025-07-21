class_name Recipe
extends Resource

var recipe_name : String
var ingredients : Array[Ingredient]
func _init (rName : String, rIngredients : Array[Ingredient]):
	recipe_name = rName
	ingredients = rIngredients
