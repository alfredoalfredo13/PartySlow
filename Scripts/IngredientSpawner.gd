class_name IngredientSpawner extends Node3D

const INGREDIENT_SCENE := preload("res://Scenes/Ingredient.tscn")
var ingredient_object : ItemController

func _ready():
	GameManager.SpawnIngredient.connect(spawn)
	spawn()
	
func spawn():
	if ingredient_object != null:
		if ingredient_object.consumed:
			ingredient_object.global_position = Vector3.FORWARD * 100000
		else:
			ingredient_object.queue_free()
	ingredient_object = INGREDIENT_SCENE.instantiate()
	add_child(ingredient_object)
	
