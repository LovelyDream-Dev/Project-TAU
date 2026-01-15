extends Control

@export var timeline:Timeline
@export var playheadColor:Color = Color.WHITE
@export var playheadWidth:float = 2.0
@export var radius = 5.0
func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var xPos = timeline.playheadOffset
	var yTop = position.y - 24.0
	var yBottom = timeline.size.y + 24.0
	# line
	draw_line(Vector2(xPos, yTop), Vector2(xPos, yBottom), playheadColor, playheadWidth, true)
	# top circle
	draw_circle(Vector2(xPos, yTop), radius, playheadColor, true, -1.0, true)
	# bottom circle
	draw_circle(Vector2(xPos, yBottom), radius, playheadColor, true, -1.0, true)
