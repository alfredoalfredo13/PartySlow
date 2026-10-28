extends Control

@export var recipe_label : Label
@export var score : Label
@onready var item_list : Array[Label] = [$Control/Quantidade, $Control/Quantidade2, $Control/Quantidade3, $Control/Quantidade4]
@onready var quantity_list : Array[Label] = [$Control/Ingrediente1, $Control/Ingrediente2, $Control/Ingrediente3, $Control/Ingrediente4]
var ingredient_dictionary : Dictionary[String, Label]

func _ready() -> void:
	GameManager.SetRecipeUI.connect(set_recipe)
	GameManager.GameStart.connect(show)
	GameManager.AddIngredientToInventory.connect(add_inventory)
	GameManager.AddScore.connect(add_score)
	
func set_recipe(recipe):
	recipe_label.text = "Current recipe:\n" + recipe.recipe_name.to_upper() + "\n\n"
	for ingredient in recipe.ingredients :
		recipe_label.text += ingredient.ingredient_name + " x1\n"
	var i = 0
	for item : Ingredient in GlobalData.currentRecipe.ingredients:
		item_list[i].text = item.ingredient_name
		quantity_list[i].text = "0 x"
		ingredient_dictionary.set(item.ingredient_name, quantity_list[i])
		i += 1
	if i < 4:
		item_list[i].text = ""
		quantity_list[i].text = ""
	
func add_score(score):
	self.score.text = str(score)
	
func add_inventory(count, nome_ingrediente):
	if count == -1:
		var i = 0
		for quantity in quantity_list:
			quantity.text = "0 x"
		return
	if ingredient_dictionary.has(nome_ingrediente):
		ingredient_dictionary[nome_ingrediente].text = "%d x" % count
		
		
