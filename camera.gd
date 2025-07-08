extends Camera3D

@export var pos1 : Vector3
@export var pos2 : Vector3
@export var rot1 : Vector3
@export var rot2 : Vector3

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("1"):
		position = pos1
		rotation = rot1
	elif Input.is_action_just_pressed("2"):
		position = pos2
		rotation = rot2
