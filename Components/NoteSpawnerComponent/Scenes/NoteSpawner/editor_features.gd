extends Node2D
class_name EditorFeatures

var notePlacementDirection:float
var minMouseDistance:float 
var editorSnapDivisor:int

var circleColor:Color:
	set(value):
		circleColor = value
		queue_redraw()
var radiusInPixels:float:
	set(value):
		radiusInPixels = value
		queue_redraw()

## Array of all beats included in the editor snap divisor. Used for snapping.
var beatPositions:Array = [1.0, 1.5, 2.0]

var parent:NoteSpawner

var localMousePos:Vector2
var closestCirclePositionToMouse:Vector2
var currentMouseBeatOnCircle:float
var distanceFromCircleToMouse:float
var currentCirclePositionFromBeat:Vector2
var notePlacementSide:float

func _ready() -> void:
	parent = get_parent()

func _process(_delta: float) -> void:
	if !CurrentMap.inEditor:
		self.hide()
		return

	queue_redraw()
	if !self.visible: self.show()
	localMousePos = get_local_mouse_position()
	notePlacementSide = parent.notePlacementSide
	editorSnapDivisor = parent.editorSnapDivisor
	notePlacementDirection = parent.notePlacementDirection
	circleColor = parent.circleColor
	radiusInPixels = parent.radiusInPixels
	minMouseDistance = parent.minMouseDistance
	get_closest_circle_position_to_mouse(parent.center)
	get_beat_from_circle_position(parent.center)
	if distanceFromCircleToMouse <= minMouseDistance:
		get_circle_position_from_beat(parent.center, currentMouseBeatOnCircle)

func _draw() -> void:
	if !CurrentMap.inEditor:
		return
	draw_circle(parent.center, radiusInPixels, circleColor, false, 4.0, true)
	if parent.debugLine:
		if localMousePos and closestCirclePositionToMouse:
			draw_line(localMousePos, closestCirclePositionToMouse, Color.WHITE)

func get_closest_circle_position_to_mouse(center:Vector2):
	var vector = localMousePos - center
	closestCirclePositionToMouse = center + vector.normalized() * radiusInPixels
	distanceFromCircleToMouse = localMousePos.distance_to(closestCirclePositionToMouse)

func get_beat_from_circle_position(center:Vector2):
	var angle = atan2(closestCirclePositionToMouse.y - center.y, closestCirclePositionToMouse.x - center.x) + notePlacementSide # PI flips the spawn side
	var normalizedAngle = fposmod(notePlacementDirection * angle, TAU)
	var value = normalizedAngle / TAU * 4
	value = snappedf(value,1.0/float(editorSnapDivisor))
	# Wrap the value around to zero if it hits 4
	if value >= 4:
		value = 0.0
	currentMouseBeatOnCircle = value

func get_circle_position_from_beat(center:Vector2, beat:float):
	var angle = ((beat * TAU / 4) / notePlacementDirection) + notePlacementSide
	var posx = center.x + radiusInPixels * cos(angle)
	var posy = center.y + radiusInPixels * sin(angle)
	currentCirclePositionFromBeat = Vector2(posx, posy)

func place_note():
	var sprite = Sprite2D.new()
	sprite.texture = load("res://Default Skin/hit-note.png")
	sprite.position = currentCirclePositionFromBeat
	self.add_child(sprite)
