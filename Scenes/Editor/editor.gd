extends Control
class_name Editor

var fileLoader = FileLoader.new() # TEMPORARY

@export var timeline:Timeline
@export var spinner:Spinner

func _process(_delta: float) -> void:
	CurrentMap.center = spinner.global_position
	if !timeline.initialCull:
		timeline.initial_note_cull()
