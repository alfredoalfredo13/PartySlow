extends CharacterBody3D

# movement speed
@export var SPEED : float = 15.0

var target_velocity = Vector3.ZERO
var inventory : Array[String]

func _physics_process(delta: float) -> void:
	move()
	if Input.is_action_just_pressed("interact"):
		print(inventory)

func move() : 
	var direction = Vector3.ZERO
	# gets movement direction based on input
	direction.z = Input.get_axis("forward", "backward")
	direction.x = Input.get_axis("left", "right")
	if direction != Vector3.ZERO:
		# normalizes so that you don't move faster diagonally
		direction = direction.normalized()
		$Pivot.basis = Basis.looking_at(direction * -1)
		# ^somehow this is backwards? multiplying by -1 fixes it
	target_velocity.x = direction.x * SPEED
	target_velocity.z = direction.z * SPEED
	velocity = target_velocity
	move_and_slide()
