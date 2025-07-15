class_name PlayerRoomController extends Node

var current_room : RoomController

func entered_room(new_room):
	if current_room != null:
		current_room.exit_room()
	current_room = new_room
	current_room.enter_room(get_parent())
	pass
