extends Node2D

var selected:bool

func _draw() -> void:
	if get_parent().selected:
		draw_circle(position, get_parent().texture.get_size().x/2, Color.WHITE, false, 5.0, true)
