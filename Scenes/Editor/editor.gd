extends Control
class_name Editor

var fileLoader = FileLoader.new() # TEMPORARY

@onready var timeline:Timeline = $TimelineMarginContainer/TimeLinePanel/Timeline

func _process(_delta: float) -> void:
	if !CurrentMap.mapLoaded:
		
		# --- THIS IS A TEST MAP
		var path = "user://maps/xaev for tau"
		fileLoader.load_map(path)
		# --- THIS IS A TEST MAP ---
		
		print("Map Loaded!")
		return

	if !timeline.initialCull:
		timeline.initial_note_cull()
