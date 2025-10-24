extends Node2D
class_name EditorFeatures

var rotationDirection:int
var minMouseDistance:float = 50.0
var editorSnapDivisor:int

## The side that editor beats begin on. [br][br][code]0[/code]: The notes start on the right. [br][br][code]PI[/code]: The notes start on the left.
@export_range(0,PI,PI) var notePlacementSide:float = PI

var circleColor:Color =Color("f44c4f")
var radiusInPixels:float:
	set(value):
		radiusInPixels = value
		queue_redraw()

## Array of all beats included in the editor snap divisor. Used for snapping.
var beatPositions:Array = [1.0, 1.5, 2.0]

var localMousePos:Vector2
var closestCirclePositionToMouse:Vector2
var currentMouseBeatOnCircle:float
var distanceFromCircleToMouse:float
var currentCirclePositionFromBeat:Vector2

func _process(_delta: float) -> void:
	if !CurrentMap.inEditor:
		self.hide()
		return

	queue_redraw()
	if !self.visible: self.show()
	localMousePos = get_local_mouse_position()
	notePlacementSide = notePlacementSide
	editorSnapDivisor = PlayerData.editorSnapDivisor
	rotationDirection = CurrentMap.rotationDirection
	radiusInPixels = CurrentMap.radiusInPixels
	get_closest_circle_position_to_mouse()
	get_beat_from_circle_position()
	if distanceFromCircleToMouse <= minMouseDistance:
		get_circle_position_from_beat(currentMouseBeatOnCircle)

func _draw() -> void:
	if !CurrentMap.inEditor:
		return
	draw_circle(Vector2.ZERO, radiusInPixels, circleColor, false, 4.0, true)
	if localMousePos and closestCirclePositionToMouse:
		draw_line(localMousePos, closestCirclePositionToMouse, Color.WHITE)

func get_closest_circle_position_to_mouse():
	var vector = localMousePos - Vector2.ZERO
	closestCirclePositionToMouse = Vector2.ZERO + vector.normalized() * radiusInPixels
	distanceFromCircleToMouse = localMousePos.distance_to(closestCirclePositionToMouse)

func get_beat_from_circle_position():
	var angle = atan2(closestCirclePositionToMouse.y - Vector2.ZERO.y, closestCirclePositionToMouse.x - Vector2.ZERO.x) + notePlacementSide # PI flips the spawn side
	var normalizedAngle = fposmod(rotationDirection * angle, TAU)
	var value = normalizedAngle / TAU * 4
	value = snappedf(value,1.0/float(editorSnapDivisor))
	# Wrap the value around to zero if it hits 4
	if value >= 4:
		value = 0.0
	currentMouseBeatOnCircle = value

func get_circle_position_from_beat(beat:float):
	var angle = ((beat * TAU / 4) / rotationDirection) + notePlacementSide
	var posx = Vector2.ZERO.x + radiusInPixels * cos(angle)
	var posy = Vector2.ZERO.y + radiusInPixels * sin(angle)
	currentCirclePositionFromBeat = Vector2(posx, posy)

func place_note():
	var sprite = Sprite2D.new()
	sprite.texture = load("res://Default Skin/hit-note.png")
	sprite.position = currentCirclePositionFromBeat
	self.add_child(sprite)
