extends Area3D
@export var itemName : String

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Players"):
		body.inventory.append(itemName)
		queue_free()
	pass # Replace with function body.
