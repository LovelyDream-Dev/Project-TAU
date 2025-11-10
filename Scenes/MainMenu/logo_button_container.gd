extends Control

func _ready() -> void:
	ShapeArranger.circular_arrangement(get_children(), pivot_offset, 500.0, 45.0, 0.0, true)
