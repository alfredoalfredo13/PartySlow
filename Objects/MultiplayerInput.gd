class_name MultiplayerInput extends MultiplayerSynchronizer

var input_direction : Vector3

func _ready() -> void:
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)

func _physics_process(delta: float) -> void:
	input_direction = Vector3.ZERO
	input_direction.z = Input.get_axis("forward", "backward")
	input_direction.x = Input.get_axis("left", "right")
	input_direction = input_direction.normalized()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("1"):
		GameManager.print_stats.rpc()
		
