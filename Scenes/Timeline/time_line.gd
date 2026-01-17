extends Control
class_name Timeline


@export_category("Nodes")
@export var timelineScroller:TimelineScroller
@export var timelineContent:TimelineContent 
@export var timelineObjectContainer:Node2D
@export_group("Colors")
## The color of the timeline background
@export var backgroundColor:Color = Color("082437b3")
@export_subgroup("Beat Ticks")
## The color of whole beat ticks
@export var wholeBeatTickColor:Color
## The color of half beat ticks
@export var halfBeatTickColor:Color
## The color of quarter beat ticks
@export var quarterBeatTickColor:Color
## The color of eighth beat ticks
@export var eighthBeatTickColor:Color
## The color of sixteenth beat ticks
@export var sixteenthBeatTickColor:Color
@export_group("Values")
## The height of the beat ticks
@export var tickHeight:float = 80.0
## The width of the beat ticks
@export var tickWidth:float = 4
## If it is true, the rectanlge that is used for tick and timeline note culling will be drawn.
@export var showCullingRect:bool
## Determines margin around the culling rectangle that ticks and timeline notes will actually cull at.
@export var cullingMargin:float = 100.0
## How many pixels represent one second on the timeline, directly affects timeline length and spacing between ticks
@export var pixelsPerSecond:float = 500.0
@export_group("Booleans")
## If the tick ends are rounded
@export var roundedTicks:bool = true
## If it is set to true, placement on the timeline via mouse clicks will be enabled
@export var timelinePlacement:bool = true
## If it is set to true, the scroll bar will be hidden
@export var hideScrollBar:bool
@export_group("Textures")
## Texture of the note that will be placed on the timeline
@export var noteTexture:Texture
@export_category("Nodes")
@export var editor:Editor

var wholeBeatTimes:Array = []
var halfBeatTimes:Array = []
var quarterBeatTimes:Array = []
var eighthBeatTimes:Array = []
var sixteenthBeatTimes:Array = []
var firstBeatTickPositionX:float

var songLengthInSeconds:float
var bpm:float 
var timelineLengthInPixels:float
var songPosition:float
var totalWholeBeats:int
var secondsPerBeat:float
var beatsPerSecond:float
var pixelsPerBeat:float

## Whether the [member timelineScroller] of the timeline is being manually scrolled by the player
var manuallyScrolling:bool

## The notes that are currently on the timeline
var timelineObjects:Array

var initialObjectOCull:bool
var initialNotesSpawned:bool

@export var playheadOffset:float = 500.0
@onready var camera = get_viewport().get_camera_2d()

func _ready() -> void:
	EditorManager.playheadOffset = playheadOffset
	EditorManager.localYPos = get_rect().size.y/2
	EditorManager.globalYPos = global_position.y + (get_rect().size.y/2)
	

func _input(_event: InputEvent) -> void:
	if !CurrentMap.is_map_loaded():
		return

func _process(_delta: float) -> void:
	CurrentMap.pixelsPerSecond = pixelsPerSecond
	queue_redraw()
	manuallyScrolling = timelineScroller.manuallyScrolling
	if !CurrentMap.is_map_loaded():
		return

	timelineObjects = timelineObjectContainer.get_children()
	# set some important values
	songLengthInSeconds = CurrentMap.songLengthInSeconds
	bpm = CurrentMap.bpm
	beatsPerSecond = CurrentMap.beatsPerSecond
	secondsPerBeat = CurrentMap.secondsPerBeat
	pixelsPerBeat = secondsPerBeat * pixelsPerSecond
	totalWholeBeats = floori(beatsPerSecond * (songLengthInSeconds + (CurrentMap.LeadInTimeMS/1000.0)))

	set_control_heights()

	# Hide the scroll bar on the scroll container
	if hideScrollBar and timelineScroller.horizontal_scroll_mode != timelineScroller.SCROLL_MODE_SHOW_NEVER:
		timelineScroller.horizontal_scroll_mode = timelineScroller.SCROLL_MODE_SHOW_NEVER
	elif !hideScrollBar and timelineScroller.horizontal_scroll_mode == timelineScroller.SCROLL_MODE_SHOW_NEVER:
		timelineScroller.horizontal_scroll_mode = timelineScroller.SCROLL_MODE_SHOW_ALWAYS

	# Spawn timeline objects at load time in the editor
	for dict:Dictionary in CurrentMap.hitObjectDicts:
		if !initialNotesSpawned:
			place_timeline_objects(dict)
	initialNotesSpawned = true
	
	get_whole_beat_times()
	get_half_beat_times()
	get_quarter_beat_times()
	get_eighth_beat_times()
	get_sixteenth_beat_times()
	firstBeatTickPositionX = GlobalFunctions.get_timeline_position_x_from_seconds(wholeBeatTimes[0], pixelsPerSecond, playheadOffset)

	set_base_control_length()

func timeline_objects_loaded() -> bool:
	if timelineObjects.size() == CurrentMap.hitObjectCount:
		return true
	else:
		return false

## Returns an [member Array] of all [member Node2D]'s within [member list] that are located at [member point].
func get_timeline_note_from_list_at_point(point:Vector2, list:Array) -> Array:
	var pointArray:Array 
	for timelineObject:TimelineObject in list:
		if timelineObject.hitObjectSprite.get_rect().has_point(timelineObject.to_local(point)):
			pointArray.append(timelineObject)
	return pointArray

## Returns the [member Node2D] with the highest [member z-index] from [member list].
func get_highest_timeline_note_z_index(list:Array) -> Node2D:
	if list.is_empty():
		return null

	var highest:TimelineObject = list[0]
	for timelineObject:TimelineObject in list:
		if timelineObject.z_index > highest.z_index:
				highest = timelineObject
	return highest

## Places notes on the timeline at the correct position using [member dict].
func place_timeline_objects(dict:Dictionary):
	timelineObjectContainer.add_child(create_timeline_object(dict, noteTexture))

## Creates timeline objects from the appropriate dictionary format; 
## [code]{hitTime: seconds, releaseTime: seconds, side: -1 or 1}[/code].
func create_timeline_object(dict:Dictionary, texture:Texture) -> TimelineObject:
	var timelineObject:TimelineObject = preload("res://Scenes/TimelineObject/timeline_object.tscn").instantiate()
	var hitTime = dict["hitTime"]
	var releaseTime = dict["releaseTime"]
	var side = GlobalFunctions.side_from_raw(dict["side"])
	
	var ypos:float = 0.0
	if side == EditorManager.sides.LEFT:
		ypos += 10
	elif side == EditorManager.sides.RIGHT:
		ypos -= 10
	var pos = Vector2(GlobalFunctions.get_timeline_position_x_from_seconds(hitTime, pixelsPerSecond, playheadOffset), EditorManager.localYPos + ypos)
	
	
	timelineObject.position = pos 
	timelineObject.dragStartPosition = pos
	timelineObject.texture = texture
	timelineObject.lastObjectDict = dict
	timelineObject.objectDict = dict
	timelineObject.hitTime = hitTime
	timelineObject.releaseTime = releaseTime
	timelineObject.side = side
	if side == EditorManager.sides.LEFT:
		timelineObject.self_modulate = PlayerData.color1
	elif side == EditorManager.sides.RIGHT:
		timelineObject.self_modulate = PlayerData.color2
	return timelineObject

# ----- TIMELINE POSITION FUNCTIONS -----

func cull_notes():
	var timelineScrollerRect:Rect2 = timelineScroller.get_rect()
	var cullingRect = Rect2(timelineScrollerRect.position - Vector2(cullingMargin, cullingMargin), timelineScrollerRect.size + Vector2(cullingMargin * 2.0, cullingMargin * 2.0))
	cullingRect.position.x += timelineScroller.scroll_horizontal
	# cull
	for timelineObject:TimelineObject in timelineObjectContainer.get_children():
		if !cullingRect.has_point(timelineObject.position):
			if !timelineObject.is_in_group("culledtimelineObjects"): 
				timelineObject.add_to_group("culledtimelineObjects")
			timelineObject.hide()
			timelineObject.process_mode = Node.PROCESS_MODE_DISABLED
	# revive
	for timelineObject:TimelineObject in get_tree().get_nodes_in_group("culledtimelineObjects"):
		if cullingRect.has_point(timelineObject.position):
			timelineObject.remove_from_group("culledtimelineObjects")
			timelineObject.show()
			timelineObject.process_mode = Node.PROCESS_MODE_INHERIT



### Uses [method valueInSeconds] to find the related pixel position on the timeline. [br]Returns [code]0.0[/code] if [method valueInSeconds] is greater than [method songLengthInSeconds].
#func get_timeline_position_x_from_song_position(valueinSeconds:float) -> float:
	#if valueinSeconds <= songLengthInSeconds:
		#return ((valueinSeconds + (CurrentMap.LeadInTimeMS/1000.0)) * pixelsPerSecond) + timelineScroller.playheadOffset
	#else: 
		#return 0.0
	
func initial_object_cull():
	initialObjectOCull = true
	cull_notes()


func set_control_heights():
	if timelineScroller.size.y != size.y: 
		timelineScroller.custom_minimum_size.y = size.y
		timelineScroller.size.y = size.y
	if timelineContent.size.y != size.y:
		timelineContent.custom_minimum_size.y = size.y
		timelineContent.size.y = size.y

func set_base_control_length():
	var leadInMS = CurrentMap.LeadInTimeMS
	var lastTickTime:float = sixteenthBeatTimes.back()
	var lastTickPositionX:float = ((lastTickTime + (leadInMS)) * pixelsPerSecond)
	timelineContent.custom_minimum_size.x = lastTickPositionX + 1920.0
	timelineContent.size.x = lastTickPositionX + 1920.0

# ----- BEAT TIME FUNCTIONS -----

func get_whole_beat_times():
	if wholeBeatTimes.is_empty() and beatsPerSecond:
		for beatIndex in range(totalWholeBeats):
			var beatTime = float(beatIndex)/beatsPerSecond
			wholeBeatTimes.append(beatTime)

func get_half_beat_times():
	if halfBeatTimes.is_empty() and beatsPerSecond:
		for beatIndex in range(totalWholeBeats*2):
			var beatTime = float(beatIndex*.5)/beatsPerSecond
			halfBeatTimes.append(beatTime)

func get_quarter_beat_times():
	if quarterBeatTimes.is_empty() and beatsPerSecond:
		for beatIndex in range(totalWholeBeats*4):
			var beatTime = float(beatIndex)/(beatsPerSecond*4)
			quarterBeatTimes.append(beatTime)

func get_eighth_beat_times():
	if eighthBeatTimes.is_empty() and beatsPerSecond:
		for beatIndex in range(totalWholeBeats*8):
			var beatTime = float(beatIndex)/(beatsPerSecond*8)
			eighthBeatTimes.append(beatTime)

func get_sixteenth_beat_times():
	if sixteenthBeatTimes.is_empty() and beatsPerSecond:
		for beatIndex in range(totalWholeBeats*16):
			var beatTime = float(beatIndex)/(beatsPerSecond*16)
			sixteenthBeatTimes.append(beatTime)

## Returns true if the necessary values to draw ticks are ready.
func get_if_ticks_are_drawable() -> bool:
	if secondsPerBeat != 0.0 and beatsPerSecond != 0.0:
		return true
	else: return false

# ----- SIGNAL FUNCTIONS -----


func _on_scroll_container_scroll_changed() -> void:
	cull_notes()
