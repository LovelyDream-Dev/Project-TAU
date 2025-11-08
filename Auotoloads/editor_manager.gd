extends Node

@warning_ignore("unused_signal")
signal SNAP_DIVISOR_CHANGED

enum modes {
	SELECT = 0,
	NOTE = 1,
	HOLDNOTE = 2,
	RAPID = 3
}
var currentMode:int = 0
var editorSnapDivisor:int = 2

## The y positon of notes on the timeline.
var yPos:float
var snappedBeat:float
var snappedPixel:float
var snappedSongPosition:float
var playheadOffset:float

func _ready() -> void:
	editorSnapDivisor = PlayerData.editorSnapDivisor
