extends Node

signal SNAP_DIVISOR_CHANGED
signal OBJECT_MOVED

enum modes {
	SELECT = 0,
	NOTE = 1,
	HOLDNOTE = 2,
	RAPID = 3
}
var currentMode:int = 0
var snapDivisor:int = 2:
	set(value):
		snapDivisor = value
		SNAP_DIVISOR_CHANGED.emit()

## The y positon of notes on the timeline.
var yPos:float
var snappedBeat:float
var snappedPixel:float
var snappedSongPosition:float
var playheadOffset:float
