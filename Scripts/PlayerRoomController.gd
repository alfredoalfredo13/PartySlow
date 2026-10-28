class_name PlayerRoomController extends Node

var current_room : RoomController
var room_queue = []
var new_room : RoomController

#Script é desativo em players não locais
	
func _on_area_entered(area: Area3D) -> void:
	if area is not RoomController:
		return
	var room = area as RoomController
	room_queue.append(room)
	if room_queue.size() == 1:
		if current_room != null:
			current_room.exit_room()
		current_room = room
		room.enter_room()

func _on_area_exited(area: Area3D) -> void:
	if area is not RoomController:
		return
	var room = area as RoomController
	if !room_queue.has(room):
		printerr("Room is not in queue")
		return
	room_queue.erase(room)
	if room_queue.is_empty():
		return
	room.exit_room()
	current_room = room_queue[0]
	current_room.enter_room()
	
	
	
	
