class_name PlayerController extends CharacterBody3D

# movement speed
@export var SPEED : float = 15.0
@export var player_data : PlayerData
@onready var id_label = $SubViewport/Label
signal notify_movement(movement_direction : Vector3)

var target_velocity = Vector3.ZERO
var inventory : Array[String]
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
	if Input.is_action_just_pressed("interact"):
		print(inventory)

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
		# ^somehow this is backwards? multiplying by -1 fixes it
	notify_movement.emit(move_dir)
	target_velocity.x = move_dir.x
	target_velocity.z = move_dir.z
	target_velocity *= delta * SPEED * 100
	velocity = target_velocity
	move_and_slide()
