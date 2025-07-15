class_name PlayerController extends CharacterBody3D

# movement speed
@export var SPEED : float = 15.0
@export var player_data : PlayerData
@onready var id_label = $SubViewport/Label
@onready var player_room_controller : PlayerRoomController = $PlayerRoomController
signal notify_movement(movement_direction : Vector3)

var target_velocity = Vector3.ZERO
var inventory : Array[String]
var completed_recipes : int = 0
var points : int = 0
var move_dir : Vector3

var sync_pos = Vector3.ZERO
var sync_rot = Vector3.ZERO

func _ready() -> void:
	player_data.remove_player.connect(
		func():
			queue_free()
	)
	sync_pos = global_position
	sync_rot = $Pivot.rotation_degrees
	pass

func seta_name(name):
	$SubViewport/Label.text = name
	$MultiplayerSynchronizer.set_multiplayer_authority(player_data.id)

func _physics_process(delta: float) -> void:
	if !$MultiplayerSynchronizer.is_multiplayer_authority():
		global_position = global_position.lerp(sync_pos, 0.5)
		$Pivot.rotation_degrees.y = lerpf($Pivot.rotation_degrees.y, sync_rot.y, 0.5)
		return
	move(delta)
	sync_pos = global_position
	sync_rot = $Pivot.rotation_degrees
	detect_recipes()
	if Input.is_action_just_pressed("interact"):
		print("points: " + str(points) + "completed recipes: " + str(completed_recipes) + " inventory: " + str(inventory))
	if Input.is_action_just_pressed("give_ingredients"):
		for i in GlobalData.currentRecipe.ingredients:
			inventory.append(i.ingredient_name)
		print("added ingredients")

func detect_recipes():
	# check for recipe's ingredients in player's inventory
	for required in GlobalData.currentRecipe.ingredients:
		if inventory.has(required.ingredient_name): continue # player has this ingredient, next
		return # player does not have this ingredient, gtfo
	
	# player has all required ingredients, remove ingredients and add completed recipe
	for required in GlobalData.currentRecipe.ingredients:
		inventory.erase(required.ingredient_name)
	completed_recipes += 1

func move(delta: float) :
	move_dir = Vector3.ZERO
	# gets movement move_dir based on input
	move_dir.z = Input.get_axis("forward", "backward")
	move_dir.x = Input.get_axis("left", "right")
	if move_dir != Vector3.ZERO:
		# normalizes so that you don't move faster diagonally
		move_dir = move_dir.normalized()
		var lerp_rotation = rotate_toward($Pivot.rotation.y, atan2(move_dir.x, move_dir.z), delta * 5)
		$Pivot.rotation.y = lerp_rotation
	notify_movement.emit(move_dir)
	target_velocity.x = move_dir.x
	target_velocity.z = move_dir.z
	target_velocity *= SPEED
	velocity = target_velocity
	move_and_slide()
