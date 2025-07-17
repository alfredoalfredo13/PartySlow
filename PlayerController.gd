class_name PlayerController extends CharacterBody3D

# movement speed
@export var SPEED : float = 15.0
@export var player_data : PlayerData
@onready var id_label = $SubViewport/Label
@onready var player_room_controller : PlayerRoomController = $PlayerRoomController
signal notify_movement(movement_direction : Vector3)

var melee_cd : float = 0.0
var melee_timer : float = 0.0
var melee_hit : Array = []
var stun : float = 0.0

var target_velocity = Vector3.ZERO
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
	if !player_data.is_local:
		GameManager.set_mesh_layer_recursive(self, 1, false)
	sync_pos = global_position
	sync_rot = $Pivot.rotation_degrees
	

func seta_name(name):
	$SubViewport/Label.text = name
	$InputSynchronizer.set_multiplayer_authority(player_data.id)
	if !player_data.is_local:
		remove_child($PlayerRoomController)

func _physics_process(delta: float) -> void:
	if !player_data.is_local:
		global_position = global_position.lerp(sync_pos, 0.5)
		$Pivot.rotation_degrees.y = lerpf($Pivot.rotation_degrees.y, sync_rot.y, 0.5)
		return
	
	# melee cooldown
	melee_cd -= delta
	# melee duration
	melee_timer -= delta
	if melee_timer <= 0.0:
		melee_hit.clear() # clears array containing hit players
	# stunned, cant do anything
	if stun > 0.0:
		stun -= delta
		return
	
	# not stunned, continue
	apply_mov_from_input(delta)
	sync_pos = global_position
	sync_rot = $Pivot.rotation_degrees
	#detect_recipes()
	if Input.is_action_just_pressed("interact"):
		melee()
	if Input.is_action_just_pressed("give_ingredients"):
		for i in GlobalData.currentRecipe.ingredients:
			player_data.inventory.append(i.ingredient_name)
		print("added ingredients")

func melee() :
	# punch what is ahead of you
	# will stun hit players
	if melee_cd > 0.0: return # already meleeing
	print("punching...")
	melee_timer = 0.3 # time that MeleeArea stays active
	melee_cd = 1.0 # cooldown before being able to melee again
	
	# get bodies inside MeleeArea
	var bodies = $Pivot/MeleeArea.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Players") and body not in melee_hit: # hit a player
			body.damaged() # stun them
			melee_hit.append(body) # so they dont get hit repeatedly from one attack
			print("HA! I hit someone!")
	

func damaged() :
	# hit by another player, gets stunned for 1.5 second
	stun = 0.5
	print("AH! I've been stunned!")

func detect_recipes():
	# check for recipe's ingredients in player's inventory
	for required in GlobalData.currentRecipe.ingredients:
		if player_data.inventory.has(required.ingredient_name): continue # player has this ingredient, next
		return # player does not have this ingredient, gtfo
	
	# player has all required ingredients, remove ingredients and add completed recipe
	for required in GlobalData.currentRecipe.ingredients:
		for ingredient in player_data.inventory:
			if required.ingredient_name != ingredient: continue
			player_data.inventory.erase(required)
			break
	completed_recipes += 1

@rpc("authority", "call_local")
func apply_mov_from_input(delta: float) :
	move_dir = $InputSynchronizer.input_direction
	if move_dir != Vector3.ZERO:
		# normalizes so that you don't apply_mov_from_input faster diagonally
		move_dir = move_dir.normalized()
		var lerp_rotation = rotate_toward($Pivot.rotation.y, atan2(move_dir.x, move_dir.z), delta * 5)
		$Pivot.rotation.y = lerp_rotation
	notify_movement.emit(move_dir)
	target_velocity.x = move_dir.x
	target_velocity.z = move_dir.z
	target_velocity *= SPEED
	velocity = target_velocity
	move_and_slide()
