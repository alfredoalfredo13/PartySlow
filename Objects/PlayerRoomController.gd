class_name PlayerRoomController extends Node

var current_room : RoomController
var room_queue = []
var new_room : RoomController


func enter_new_room(room_exited_from : RoomController):
	if room_exited_from == new_room:
		print("oops room_exited_from ", room_exited_from.get_parent(), " == new_room ", new_room.get_parent())
		return
	if current_room != null:
		current_room.exit_room()
	current_room = new_room


func set_new_room(new_room):
	self.new_room = new_room
	if current_room != null:	
		return
	current_room = new_room
	
func _on_area_entered(area: Area3D) -> void:
	if area is not RoomController:
		return
	var room = area as RoomController
	room_queue.append(room)
	if room_queue.size() == 1:
		if current_room != null:
			current_room.exit_room()
		current_room = room
		room.change_room()

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
	current_room.change_room()
	
	
	
	
