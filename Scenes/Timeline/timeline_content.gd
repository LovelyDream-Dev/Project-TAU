extends ColorRect
class_name TimelineContent

@export var timeline:Timeline

func _process(_delta: float) -> void:
	queue_redraw()
	get_snapped_values()

func get_snapped_values():
	## Snap is off by -7 pixels, this is added to correct it
	var pixelOffsetCorrection: float = 7.0
	var pixelsPerBeat = timeline.pixelsPerBeat
	var secondsPerBeat = timeline.secondsPerBeat
	if self.get_rect().has_point(self.get_local_mouse_position()):
		var mouseTimelinePosition = self.get_local_mouse_position().x 
		var mouseBeatPosition = (mouseTimelinePosition / pixelsPerBeat) 
		var snapInterval = 1.0/float(EditorManager.snapDivisor)
		EditorManager.snappedBeat = round(mouseBeatPosition / snapInterval) * snapInterval
		EditorManager.snappedPixel = (EditorManager.snappedBeat * pixelsPerBeat) + pixelOffsetCorrection
		EditorManager.snappedSongPosition = EditorManager.snappedBeat * secondsPerBeat
