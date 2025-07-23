extends Panel

@onready var tag : Label = $Preset
var tag_dictionary : Dictionary[int, Label] = {}

var index : int = 0

func _ready() -> void:
	NetworkManager.add_to_lobby.connect(add_new)
	NetworkManager.remove_from_lobby.connect(remove)
	
func add_new(name, id):
	print("LOBBY")
	var new_tag : Label = tag.duplicate()
	$VBoxContainer.add_child(new_tag)
	new_tag.text = name
	tag_dictionary.set(id, new_tag)
	
func remove(id):
	if tag_dictionary.has(id):
		tag_dictionary[id].queue_free()
		tag_dictionary.erase(id)
	if id == -1:
		for tag : Control in tag_dictionary.values():
			tag.queue_free()
		tag_dictionary.clear()
		visible = false
