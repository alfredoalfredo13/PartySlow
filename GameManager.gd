extends Node

var players : Dictionary = {}

func set_mesh_layer_recursive(node: Node, layer: int, visible : bool):
	if node is VisualInstance3D:
			var mesh = node as VisualInstance3D
			mesh.set_layer_mask_value(layer, visible)
	for child in node.get_children():
		set_mesh_layer_recursive(child, layer, visible)
