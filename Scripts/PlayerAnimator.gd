class_name PlayerAnimator extends Node3D
 
@onready var animation_player = $AnimationPlayer


func _on_player_notify_movement(dir: Vector3) -> void:
	if dir.length() <= 0:
		animation_player.play("Idle")
	else: 
		animation_player.play("Walking_A")
