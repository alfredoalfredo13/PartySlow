extends Node
var ingredients : Array[Ingredient] = []
var recipes : Array[Recipe] = []
var currentRecipe : Recipe

func _ready() -> void:
	createIngredients()
	print("created ingredients")
	createRecipes()
	print("created recipes")


func createIngredients():
	ingredients.append(Ingredient.new("Bun", "Bread"))
	ingredients.append(Ingredient.new("Lettuce", "Vegetable"))
	ingredients.append(Ingredient.new("Cheese", "Dairy"))
	ingredients.append(Ingredient.new("Burger", "Meat"))
	ingredients.append(Ingredient.new("Potato", "Vegetable"))
	ingredients.append(Ingredient.new("Onion", "Vegetable"))
	ingredients.append(Ingredient.new("Carrot", "Vegetable"))
	ingredients.append(Ingredient.new("Chicken", "Meat"))
	ingredients.append(Ingredient.new("Tomato", "Vegetable"))

func createRecipes():
	recipes.append(Recipe.new("Cheeseburger",[
		get_ingredient("Bun"),
		get_ingredient("Lettuce"),
		get_ingredient("Cheese"),
		get_ingredient("Burger")
		]))
	recipes.append(Recipe.new("Stew", [
		get_ingredient("Potato"),
		get_ingredient("Onion"),
		get_ingredient("Carrot"),
		get_ingredient("Tomato")
	]))
	recipes.append(Recipe.new("Hamburger", [
		get_ingredient("Bun"),
		get_ingredient("Onion"),
		get_ingredient("Tomato"),
		get_ingredient("Burger")
	]))
	recipes.append(Recipe.new("Chicken salad", [
		get_ingredient("Chicken"),
		get_ingredient("Lettuce"),
		get_ingredient("Tomato"),
		get_ingredient("Onion")
	]))
	recipes.append(Recipe.new("Stuffed potato", [
		get_ingredient("Potato"),
		get_ingredient("Burger"),
		get_ingredient("Cheese")
	]))

func setCurrentRecipe(index):
	currentRecipe = recipes[index]
	print("set current: " + currentRecipe.recipe_name)

func get_ingredient(iName : String) -> Ingredient:
	for ingredient in ingredients:
		if ingredient.ingredient_name == iName:
			return ingredient
	return null
