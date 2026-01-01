extends Node

@warning_ignore("unused_signal")
signal SNAP_DIVISOR_CHANGED
signal SNAPPED_PIXEL_CHANGED

enum modes {
	SELECT = 0,
	NOTE = 1,
	HOLDNOTE = 2,
	RAPID = 3
}
var currentMode:int = 0
var editorSnapDivisor:int = 2
var editorSnapInterval:float = 0.0
var linkMap:LinkMap = LinkMap.new()

## The global y positon of notes on the timeline.
var globalYPos:float
## The local y position of notes on the timeline
var localYPos:float

var snappedBeat:float
var _snappedPixel:float = 0.0
var snappedPixel:float:
	set(value):
		if value == _snappedPixel:
			return
		_snappedPixel = value
		emit_signal("SNAPPED_PIXEL_CHANGED", value)
	get:
		return _snappedPixel
var snappedSongPosition:float
var playheadOffset:float

func _ready() -> void:
	editorSnapDivisor = PlayerData.editorSnapDivisor

func _process(_delta: float) -> void:
	if !CurrentMap.inEditor or !CurrentMap.is_map_loaded():
		return

	editorSnapInterval = CurrentMap.secondsPerBeat / editorSnapDivisor
