extends Control
class_name Editor

@onready var timeline:Timeline = $TimelineMarginContainer/TimeLinePanel/Timeline

func _process(_delta: float) -> void:
	if !timeline.initialCull and CurrentMap.mapLoaded:
		timeline.initial_note_cull()
