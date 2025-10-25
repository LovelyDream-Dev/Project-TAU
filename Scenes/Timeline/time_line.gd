extends Control
class_name Timeline

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

var wholeBeatTimes:Array = []
var halfBeatTimes:Array = []
var quarterBeatTimes:Array = []
var eighthBeatTimes:Array = []
var sixteenthBeatTimes:Array = []

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

var dragSelectStartPosition:Vector2
var dragSelectStarted:bool = false
var dragSelectionRect:Rect2
var dragNoteStartPosX:float

var initialObjectOCull:bool
var initialNotesSpawned:bool

@onready var playheadOffset:float = $PlayHead.position.x
@onready var timelineScroller:TimelineScroller = $TimelineScroller
@onready var timelineContent:TimelineContent = $TimelineScroller/TimelineContent
@onready var timelineObjectContainer:Node2D = $TimelineScroller/TimelineContent/TimelineObjectContainer
@onready var camera = get_viewport().get_camera_2d()

func _ready() -> void:
	EditorManager.playheadOffset = playheadOffset
	EditorManager.yPos = self.get_rect().size.y/2

func _input(event: InputEvent) -> void:
	if !CurrentMap.mapLoaded:
		return

	if Input.is_action_just_pressed("LMB"):
		start_note_drag()

	if Input.is_action_pressed("LMB"):
		drag_notes()
		if get_tree().get_node_count_in_group("selectedNotes") == 0:
			if !dragSelectStarted:
				dragSelectStarted = true
				dragSelectStartPosition = get_local_mouse_position()
		else:
			if dragSelectStarted:
				deselect_notes(null)

	if Input.is_action_just_released("LMB"):
		end_note_drag()
		dragSelectStarted = false

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			deselect_notes(null)


func _process(_delta: float) -> void:
	CurrentMap.pixelsPerSecond = pixelsPerSecond
	queue_redraw()
	manuallyScrolling = timelineScroller.manuallyScrolling
	if !CurrentMap.mapLoaded:
		return

	# set some important values
	songLengthInSeconds = CurrentMap.songLengthInSeconds
	bpm = CurrentMap.bpm
	beatsPerSecond = CurrentMap.beatsPerSecond
	secondsPerBeat = CurrentMap.secondsPerBeat
	pixelsPerBeat = secondsPerBeat * pixelsPerSecond
	totalWholeBeats = floori(beatsPerSecond * (songLengthInSeconds + (CurrentMap.LeadInTimeMS/1000.0)))

	# manage drag selection
	#select_notes_by_drag()

	set_control_heights()

	# Hide the scroll bar on the scroll container
	if hideScrollBar and timelineScroller.horizontal_scroll_mode != timelineScroller.SCROLL_MODE_SHOW_NEVER:
		timelineScroller.horizontal_scroll_mode = timelineScroller.SCROLL_MODE_SHOW_NEVER
	elif !hideScrollBar and timelineScroller.horizontal_scroll_mode == timelineScroller.SCROLL_MODE_SHOW_NEVER:
		timelineScroller.horizontal_scroll_mode = timelineScroller.SCROLL_MODE_SHOW_ALWAYS

	# Spawn timeline objects at load time in the editor
	for dict:Dictionary in CurrentMap.hitObjects:
		if !initialNotesSpawned:
			place_timeline_objects(dict)
	initialNotesSpawned = true
	
	get_whole_beat_times()
	get_half_beat_times()
	get_quarter_beat_times()
	get_eighth_beat_times()
	get_sixteenth_beat_times()

	set_base_control_length()



func _draw() -> void:
	#if dragSelectStarted:
		#draw_selection_rectangle(dragSelectStartPosition)
	pass

## Draws the rect for multi note selection.
func draw_selection_rectangle(pos:Vector2):
	var mousePos = get_local_mouse_position()
	var movingCorner = Vector2(mousePos.x - pos.x, mousePos.y - pos.y)
	dragSelectionRect = Rect2(pos, movingCorner)
	draw_rect(dragSelectionRect, Color(1, 1, 1, 0.5), true)
	draw_rect(dragSelectionRect, Color(1, 1, 1, 1), false)

func select_notes_by_drag():
	if !dragSelectStarted:
		if get_tree().get_node_count_in_group("selectedNotes") > 0:
			return
	else:
		for timelineObject:TimelineObject in timelineObjectContainer.get_children():
			if dragSelectionRect.abs().has_point(timelineObjectContainer.to_local(timelineObject.global_position)):
				timelineObject.isSelected = true

## De-selects [member note] if it is not [code]null[/code]. Otherwise it de-selects all notes in group [member selectedNotes].
func deselect_notes(note:TimelineObject):
	if note == null:
		for timelineObject:TimelineObject in get_tree().get_nodes_in_group("selectedNotes"):
			timelineObject.isSelected = false
	else:
		note.isSelected = false

## Returns [member true] if a mouse click is detected outside of any node within group [member selectedNotes].
func get_if_clicked_outside_of_selected_note() -> bool:
	for timelineObject:TimelineObject in get_tree().get_nodes_in_group("selectedNotes"):
		if !timelineObject.hitObjectSprite.get_rect().has_point(timelineObject.hitObjectSprite.get_local_mouse_position()):
			return true
		else: 
			return false
	return true

func start_note_drag():
	dragNoteStartPosX = EditorManager.snappedPixel

func drag_notes():
	if !dragSelectStarted:
		for timelineObject:TimelineObject in get_tree().get_nodes_in_group("selectedNotes"):
			var dragDistance = (EditorManager.snappedPixel - dragNoteStartPosX)
			timelineObject.position.x = timelineObject.currentPositionX + dragDistance
			

func end_note_drag():
	for timelineObject:TimelineObject in get_tree().get_nodes_in_group("selectedNotes"):
		timelineObject.currentPositionX = timelineObject.position.x
	dragNoteStartPosX = 0.0

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
	var timelineObjectTexture = load("res://Images/Editor/Timeline/timeline-note.png")
	timelineObjectContainer.add_child(create_timeline_object(dict, timelineObjectTexture))

## Creates timeline objects from the appropriate dictionary format; 
## [code]{hitTime: seconds, releaseTime: seconds, side: -1 or 1}[/code].
func create_timeline_object(dict:Dictionary, texture:Texture) -> TimelineObject:
	var timelineObject:TimelineObject = preload("res://Scenes/TimelineObject/timeline_object.tscn").instantiate()
	var hitTime = dict["hitTime"]
	var releaseTime = dict["releaseTime"]
	var side = GlobalFunctions.side_from_raw(dict["side"])
	var pos = Vector2(GlobalFunctions.get_timeline_position_x_from_seconds(hitTime, pixelsPerSecond, playheadOffset), EditorManager.yPos)
	timelineObject.position = pos
	timelineObject.texture = texture
	timelineObject.lastObjectDict = dict
	timelineObject.hitTime = hitTime
	timelineObject.releaseTime = releaseTime
	timelineObject.side = side
	if side == GlobalFunctions.side.LEFT:
		timelineObject.modulate = PlayerData.color1
	elif side == GlobalFunctions.side.RIGHT:
		timelineObject.modulate = PlayerData.color2
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



## Uses [method valueInSeconds] to find the related pixel position on the timeline. [br]Returns [code]0.0[/code] if [method valueInSeconds] is greater than [method songLengthInSeconds].
func get_timeline_position_x_from_song_position(valueinSeconds:float) -> float:
	if valueinSeconds <= songLengthInSeconds:
		return ((valueinSeconds + (CurrentMap.LeadInTimeMS/1000.0)) * pixelsPerSecond) + timelineScroller.playheadOffset
	else: 
		return 0.0
	
func initial_object_cull():
	initialObjectOCull = true
	cull_notes()


func set_control_heights():
	if timelineScroller.size.y != self.size.y: 
		timelineScroller.custom_minimum_size.y = self.size.y
		timelineScroller.size.y = self.size.y
	if timelineContent.size.y != self.size.y:
		timelineContent.custom_minimum_size.y = self.size.y
		timelineContent.size.y = self.size.y

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
