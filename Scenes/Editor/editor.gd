extends Control
class_name Editor

var fileLoader = FileLoader.new() # TEMPORARY

@export var timeline:Timeline
@export var spinner:Spinner

func _enter_tree() -> void:
	CurrentMap.inEditor = true

func _process(_delta: float) -> void:
	if !timeline.initialCull:
		timeline.initial_note_cull()
