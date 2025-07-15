class_name PlayerRoomController extends Node

var current_room : RoomController
var new_room : RoomController

func enter_new_room():
	if current_room != null:
		current_room.exit_room()
	current_room = new_room
	current_room.enter_room(get_parent())

func set_new_room(new_room):
	self.new_room = new_room
	if current_room == null:	
		enter_new_room()
