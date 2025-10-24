extends Control
class_name Editor

@export var timeline:Timeline
@export var spinner:Spinner

func _enter_tree() -> void:
	CurrentMap.inEditor = true

func _process(_delta: float) -> void:
	if !timeline.initialObjectOCull:
		timeline.initial_object_cull()
