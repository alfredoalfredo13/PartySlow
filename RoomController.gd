class_name RoomController extends Area3D
@export var camera_pos : Vector3
@export var layer : int
var players_list = []
var is_player_here = false

func _ready() -> void:
	GameManager.set_mesh_layer_recursive(get_parent(), 1, false)	
	GameManager.set_mesh_layer_recursive(get_parent(), layer, true)	

func _on_body_entered(body: Node3D) -> void:
	if body is not PlayerController:
		return
	var player = body as PlayerController
	players_list.append(player)
	if !player.player_data.is_local:
		GameManager.set_mesh_layer_recursive(body, layer, true)
		return
	print("Player entered ", get_parent().name)
	player.player_room_controller.set_new_room(self)

func enter_room(player : Node3D):
	var camera = get_viewport().get_camera_3d()
	camera.set_cull_mask_value(layer, true)
	var tween = get_tree().create_tween()
	var next_pos = Vector3.UP * 11 + Vector3.BACK * (12 + global_position.z) + Vector3.RIGHT * global_position.x
	tween.tween_property(camera, "position", next_pos, 0.2).set_ease(Tween.EASE_OUT_IN)
	
func exit_room():
	print("Player exited ", get_parent().name)
	var camera = get_viewport().get_camera_3d()
	camera.set_cull_mask_value(layer, false)

func _on_body_exited(body: Node3D) -> void:
	if body is not PlayerController:
		return
	var player = body as PlayerController
	if !player.player_data.is_local:
		GameManager.set_mesh_layer_recursive(body, layer, false)
		return
	print("collision exited ", get_parent().name)
	player.player_room_controller.enter_new_room()

# Example usage:
# Assuming you have a root node called "SceneRoot"
# and you want to set the layer to 2 and mask to 3
