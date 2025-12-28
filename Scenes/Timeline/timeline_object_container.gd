extends Node2D


func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	for object:TimelineObject in get_tree().get_nodes_in_group("selectedObjects"):
		draw_circle(object.position, object.texture.get_size().x/2, Color.WHITE, false, 5.0, true)
