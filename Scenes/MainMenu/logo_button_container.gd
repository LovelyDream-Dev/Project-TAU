extends Control

func _ready() -> void:
	ShapeArranger.circular_control_arrangement(get_children(), get_rect().get_center(), 45.0, 0.0, true)
