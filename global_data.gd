extends Node
var ingredients : Array[Ingredient] = []
var recipes : Array[Recipe] = []
var currentRecipe : Recipe

func _ready() -> void:
	createIngredients()
	createRecipes()

func createIngredients():
	ingredients.append(Ingredient.new("Bun", "Bread"))
	ingredients.append(Ingredient.new("Lettuce", "Vegetable"))
	ingredients.append(Ingredient.new("Cheese", "Dairy"))
	ingredients.append(Ingredient.new("Burger", "Meat"))

func createRecipes():
	recipes.append(Recipe.new("Hamburger",
		[get_ingredient("Bun"),
		get_ingredient("Lettuce"),
		get_ingredient("Cheese"),
		get_ingredient("Burger")
		]))
	#recipes.append(Recipe.new("TestRecipe", []))

func get_ingredient(iName : String) -> Ingredient:
	for ingredient in ingredients:
		if ingredient.ingredient_name == iName:
			return ingredient
	return null
