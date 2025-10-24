extends Node2D

@export var timeline:Timeline
@export var timelineScroller:TimelineScroller

var initialTicksDrawn:bool

# The last scroll position of the scrollContainer. Used to determine if the scroll container has scrolled.
var lastScrollX:float = 0

var cullingMargin:float
var showCullingRect:bool

func _process(_delta: float) -> void:
	cullingMargin = timeline.cullingMargin
	showCullingRect = timeline.showCullingRect
	if !initialTicksDrawn and timeline.get_if_ticks_are_drawable():
		queue_redraw()
		initialTicksDrawn = true

	# Determine if the scroll container has scrolled
	var currentScrollX = timelineScroller.scroll_horizontal
	if lastScrollX != currentScrollX:
		lastScrollX = currentScrollX
		on_scroll_changed()

func draw_beat_ticks(BeatTime:float, tickHeight:float, tickWidth:float, tickColor:Color, rounded:bool):
	var xPosition = GlobalFunctions.get_timeline_position_x_from_seconds(BeatTime, timeline.pixelsPerSecond, timeline.playheadOffset)
	var yCenter = timeline.position.y + (timeline.get_rect().size.y/2)
	
	#  \/ --- BEAT TICK CULLING WITH MARGIN --- \/

	# Get the visible rect of the scrollcontainer
	var timelineScrollerRect:Rect2 = timelineScroller.get_rect()
	var cullingRect = Rect2(timelineScrollerRect.position - Vector2(cullingMargin, cullingMargin), timelineScrollerRect.size + Vector2(cullingMargin * 2.0, cullingMargin * 2.0))
	cullingRect.position.x += timelineScroller.scroll_horizontal
	var tickPos = Vector2(xPosition, yCenter)
	if !cullingRect.has_point(tickPos):
		return
	if showCullingRect:
		var visualDefaultRect:Rect2 = timelineScrollerRect
		visualDefaultRect.position.x += timelineScroller.scroll_horizontal
		draw_rect(cullingRect, Color.YELLOW, false)
		draw_rect(visualDefaultRect, Color.RED, false)
	
	# /\ --- BEAT TICK CULLING WITH MARGIN --- /\

	draw_line(Vector2(xPosition, yCenter + (tickHeight/2)), Vector2(xPosition, yCenter - (tickHeight/2)), tickColor, tickWidth, true)
	if rounded:
		draw_circle(Vector2(xPosition, yCenter + (tickHeight/2)), tickWidth/2, tickColor, true, -1.0, true)
		draw_circle(Vector2(xPosition, yCenter - (tickHeight/2)), tickWidth/2, tickColor, true, -1.0, true)

## Checks if the given tick time is overlapped with another tick time of a different type (1: Whole tick 2: half tick 4: quarter tick, etc...), allowing said time to be excluded if it is a member of a smaller snap divisor. [br]Whole ticks are never excluded, tick type of 1 will have no effect.
func get_if_tick_time_overlaps(tickTime:float, tickType:int):
	if tickType == 2: # half ticks
		if tickTime in timeline.wholeBeatTimes:
			return true
	elif tickType == 4: # quarter ticks
		if tickTime in timeline.halfBeatTimes:
			return true
	elif tickType == 8: # eighth ticks
		if tickTime in timeline.quarterBeatTimes:
			return true
	elif tickType == 16: # sixteenth ticks
		if tickTime in timeline.eighthBeatTimes:
			return true

func _draw() -> void:
	# Draw whole ticks (always drawn)
	for i in range(len(timeline.wholeBeatTimes)):
		var wholeBeatTime = timeline.wholeBeatTimes[i]
		var isFourth = (i % 4 == 0)
		var tickwidth = timeline.tickWidth if isFourth else timeline.tickWidth * 0.7
		var fourthTickHeight:float = timeline.get_rect().size.y-10
		var tickHeight = fourthTickHeight if isFourth else timeline.tickHeight * 0.95
		draw_beat_ticks(wholeBeatTime, tickHeight, tickwidth, timeline.wholeBeatTickColor, timeline.roundedTicks)

	# Draw half ticks
	if timeline.snapDivisor >= 2: 
		for halfBeatTime in timeline.halfBeatTimes:
			if !get_if_tick_time_overlaps(halfBeatTime, 2):
				var tickHeight = timeline.tickHeight * 0.85
				var tickwidth = timeline.tickWidth * 0.65
				draw_beat_ticks(halfBeatTime, tickHeight, tickwidth, timeline.halfBeatTickColor, timeline.roundedTicks)

	# Draw quarter ticks
	if timeline.snapDivisor >= 4: 
		for quarterBeatTime in timeline.quarterBeatTimes: 
			if !get_if_tick_time_overlaps(quarterBeatTime, 4):
				var tickHeight = timeline.tickHeight * 0.75
				var tickwidth = timeline.tickWidth * 0.6
				draw_beat_ticks(quarterBeatTime, tickHeight, tickwidth, timeline.quarterBeatTickColor, timeline.roundedTicks)

	# Draw eighth ticks
	if timeline.snapDivisor >= 8: 
		for eighthBeatTime in timeline.eighthBeatTimes: 
			if !get_if_tick_time_overlaps(eighthBeatTime, 8):
				var tickHeight = timeline.tickHeight * 0.65
				var tickwidth = timeline.tickWidth * 0.55
				draw_beat_ticks(eighthBeatTime, tickHeight, tickwidth, timeline.eighthBeatTickColor, timeline.roundedTicks)

	# Draw sixteenth ticks
	if timeline.snapDivisor >= 16: 
		for sixteenthBeatTime in timeline.sixteenthBeatTimes: 
			if !get_if_tick_time_overlaps(sixteenthBeatTime, 16):
				var tickHeight = timeline.tickHeight * 0.55
				var tickwidth = timeline.tickWidth * 0.5
				draw_beat_ticks(sixteenthBeatTime, tickHeight, tickwidth, timeline.sixteenthBeatTickColor, timeline.roundedTicks)

## Refreshes beat ticks
func refresh_ticks():
	queue_redraw()

func on_scroll_changed():
	refresh_ticks()

func on_timeline_2d_snap_divisor_changed() -> void:
	refresh_ticks()
