extends CharacterBody3D

# movement speed
@export var SPEED : float = 15.0
signal notify_movement(movement_direction : Vector3)

var target_velocity = Vector3.ZERO
var inventory : Array[String]
var move_dir : Vector3

func _physics_process(delta: float) -> void:
	move(delta)
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
	notify_movement.emit(move_dir)
	target_velocity.x = move_dir.x
	target_velocity.z = move_dir.z
	target_velocity *= SPEED
	velocity = target_velocity
	move_and_slide()
