extends Control
class_name Timeline

signal SNAP_DIVISOR_CHANGED

@export_category("Colors")
## The color of the timeline background
@export var backgroundColor:Color
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
@export_category("Values")
## The height of the beat ticks
@export var tickHeight:float = 80.0
## The width of the beat ticks
@export var tickWidth:float = 4
## If it is true, the rectanlge that is used for tick and timeline note culling will be drawn.
@export var showCullingRect:bool
## Determines margin around the culling rectangle that ticks and timeline notes will actually cull at.
@export var cullingMargin:float = 100.0
## Determines the amount of ticks between each whole beat.
@export_range(1,16) var snapDivisor:int:
	set(value):
		snapDivisor = value
		_on_snap_divisor_changed()
## How many pixels represent one second on the timeline, directly affects timeline length and spacing between ticks
@export var pixelsPerSecond:float = 500.0
@export_category("Booleans")
## If the tick ends are rounded
@export var roundedTicks:bool = true
## If it is set to true, placement on the timeline via mouse clicks will be enabled
@export var timelinePlacement:bool = true
## If it is set to true, the scroll bar will be hidden
@export var hideScrollBar:bool

@export_category("Textures")
## Texture of the note that will be placed on the timeline
@export var noteTexture:Texture

# --- ARRAYS ---
## Array of the times in seconds of all whole beats within the song
var wholeBeatTimes:Array = []
## Array of the times in seconds of all half beats within the song
var halfBeatTimes:Array = []
## Array of the times in seconds of all quarter beats within the song
var quarterBeatTimes:Array = []
## Array of the times in seconds of all eighth beats within the song
var eighthBeatTimes:Array = []
## Array of the times in seconds of all sixteenth beats within the song
var sixteenthBeatTimes:Array = []

# --- VALUES ---
var songLengthInSeconds:float
var bpm:float 
## Length of the timeline in pixels
var timelineLengthInPixels:float
## If applicable, the current position of the song.
var songPosition:float
## If applicable, the total amount of whole beats in the song.
var totalWholeBeats:int
## How many seconds a whole beat lasts
var secondsPerBeat:float
## How many whole beats are in a second
var beatsPerSecond:float
## How many pixels are in a whole beat on the timeline
var pixelsPerBeat:float

# --- SNAPPING VARIABLES ---
# The position of the mouse in beats on the timeline
var mouseBeatPosition:float
## The nearest beat snap, this number DOES NOT indicate overral beat numbers. It counts beats sequentially depending on the snap divisor. [br]For example, with half beats it will count the first whole beat as 0, and the half beat after as 1.
var snappedBeat:float
# The nearest snap point in pixels
var snappedPixel:float
## The song position that is used as a snap point that the mouse is closest to
var snappedSongPosition:float
## The snap interval to determine beat ticks and snapping
var snapInterval:float

# The local position of the mouse in pixels on the timeline
var mouseTimelinePosition:float

## Whether the [member ScrollContainer] of the timeline is being manually scrolled by the player
var manuallyScrolling:bool

## The notes that are currently on the timeline
var timelineObjects:Array

# --- DRAGGING VARIABLES ---

var dragSelectStartPosition:Vector2
var dragSelectStarted:bool = false
var dragSelectionRect:Rect2
var dragNoteStartPosX:float

## If [member initial_note_cull] has been initially called.
var initialCull:bool
var initialNotesSpawned:bool

@onready var scrollContainer:ScrollContainer = $ScrollContainer
@onready var baseControl:ColorRect = $ScrollContainer/BaseControl
@onready var noteContainer:Node2D = $ScrollContainer/BaseControl/NoteContainer
@onready var camera = get_viewport().get_camera_2d()

func _on_snap_divisor_changed():
	SNAP_DIVISOR_CHANGED.emit()

func _input(event: InputEvent) -> void:
	if !CurrentMap.mapLoaded:
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			select_notes_by_click(event)
			if get_if_clicked_outside_of_selected_note() == true:
				deselect_notes(null)

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

		# Get the timeline mouse position if the mouse is moving within the timeline
	if scrollContainer.get_rect().has_point(scrollContainer.get_local_mouse_position()):
		if event is InputEventMouseMotion:
			mouseTimelinePosition = scrollContainer.make_input_local(event).position.x + scrollContainer.scroll_horizontal




func _process(_delta: float) -> void:
	queue_redraw()
	manuallyScrolling = scrollContainer.manuallyScrolling
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
	select_notes_by_drag()

	# manage snapping
	mouseBeatPosition = (mouseTimelinePosition / pixelsPerBeat) 
	get_snapped_position()
	set_control_heights()

	# Hide the scroll bar on the scroll container
	if hideScrollBar and scrollContainer.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_SHOW_NEVER:
		scrollContainer.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	elif !hideScrollBar and scrollContainer.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_SHOW_NEVER:
		scrollContainer.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS

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
	if initialNotesSpawned:
		manage_notes()



func _draw() -> void:
	if dragSelectStarted:
		draw_selection_rectangle(dragSelectStartPosition)


# --- CUSTOM FUNCTIONS ---
# ----- DRAWING FUNCTIONS -----


## Draws the rectangle for multi note selection
func draw_selection_rectangle(pos:Vector2):
	var mousePos = get_local_mouse_position()
	var movingCorner = Vector2(mousePos.x - pos.x, mousePos.y - pos.y)
	dragSelectionRect = Rect2(pos, movingCorner)
	draw_rect(dragSelectionRect, Color(1, 1, 1, 0.5), true)
	draw_rect(dragSelectionRect, Color(1, 1, 1, 1), false)


# ----- TIMELINE _NOTE FUNCTIONS -----

## Selects timeline objects on mouse click. Can only select individual notes if none are already selected.
func select_notes_by_click(event:InputEvent):
	if get_tree().get_node_count_in_group("selectedNotes") > 0:
		return

	var nodesUnderEvent:Array = get_timeline_note_from_list_at_point(event.position, noteContainer.get_children())
	if !nodesUnderEvent.is_empty():
		var topNote:TimelineObject = nodesUnderEvent.back()
		topNote.isSelected = true

func select_notes_by_drag():
	if !dragSelectStarted:
		if get_tree().get_node_count_in_group("selectedNotes") > 0:
			return
	else:
		for timelineObject:TimelineObject in noteContainer.get_children():
			if dragSelectionRect.abs().has_point(noteContainer.to_local(timelineObject.global_position)):
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
	dragNoteStartPosX = snappedPixel

func drag_notes():
	if !dragSelectStarted:
		for timelineObject:TimelineObject in get_tree().get_nodes_in_group("selectedNotes"):
			var dragDistance = (snappedPixel - dragNoteStartPosX)
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

func manage_notes():
	for dict:Dictionary in timelineObjects:
		if dict not in CurrentMap.hitObjects:
			CurrentMap.hitObjects.append(dict)
			CurrentMap.sort_hit_objects()
	for dict:Dictionary in CurrentMap.hitObjects:
		if dict not in timelineObjects:
			CurrentMap.hitObjects.erase(dict)
			CurrentMap.sort_hit_objects()

## Places notes on the timeline at the correct position using [member beat].
func place_timeline_objects(dict:Dictionary):
	var timelineObjectTexture = load("res://Images/Timeline/timeline-note.png")
	var timelineObject:TimelineObject = create_timeline_object(dict, timelineObjectTexture)
	noteContainer.add_child(timelineObject)

## Creates timeline objects from the appropriate dictionary format; [code]{hitTime: seconds, releaseTime: seconds, side: -1 or 1}[/code].
func create_timeline_object(dict:Dictionary, texture:Texture) -> TimelineObject:
	var timelineObject:TimelineObject = TimelineObject.new()
	var hitTime = dict["hitTime"]
	var releaseTime = dict["releaseTime"]
	var side = dict["side"]
	var startPos = get_timeline_position_from_seconds(hitTime)
	var endPos = get_timeline_position_from_seconds(releaseTime)
	timelineObject.position = startPos
	timelineObject.hitObjectTexture = texture
	timelineObject.startPos = startPos
	timelineObject.endPos = endPos
	timelineObject.side = side
	return timelineObject

# ----- TIMELINE POSITION FUNCTIONS -----


func cull_notes():
	var scrollContainerRect:Rect2 = scrollContainer.get_rect()
	var cullingRect = Rect2(scrollContainerRect.position - Vector2(cullingMargin, cullingMargin), scrollContainerRect.size + Vector2(cullingMargin * 2.0, cullingMargin * 2.0))
	cullingRect.position.x += scrollContainer.scroll_horizontal
	# cull
	for timelineObject:TimelineObject in noteContainer.get_children():
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

func get_timeline_position_from_seconds(valueInSeconds:float) -> Vector2:
	var posx = (valueInSeconds * pixelsPerSecond) + scrollContainer.playheadOffset
	var posy = self.get_rect().size.y/2
	return Vector2(posx, posy)

## Assigns the closest snap position to [member snappedPosition] based on the mouse position on the timeline.
func get_snapped_position():
	snapInterval = 1.0/float(snapDivisor)
	snappedBeat = round(mouseBeatPosition / snapInterval) * snapInterval
	snappedPixel = snappedBeat * pixelsPerBeat
	snappedSongPosition = snappedBeat * secondsPerBeat

## Uses [method valueInSeconds] to find the related pixel position on the timeline. [br]Returns [code]0.0[/code] if [method valueInSeconds] is greater than [method songLengthInSeconds].
func get_timeline_position_x_from_song_position(valueinSeconds:float) -> float:
	if valueinSeconds <= songLengthInSeconds:
		return ((valueinSeconds + (CurrentMap.LeadInTimeMS/1000.0)) * pixelsPerSecond) + scrollContainer.playheadOffset
	else: 
		return 0.0
	
func initial_note_cull():
	initialCull = true
	cull_notes()


func set_control_heights():
	if scrollContainer.size.y != self.size.y: 
		scrollContainer.custom_minimum_size.y = self.size.y
		scrollContainer.size.y = self.size.y
	if baseControl.size.y != self.size.y:
		baseControl.custom_minimum_size.y = self.size.y
		baseControl.size.y = self.size.y

func set_base_control_length():
	var leadInMS = CurrentMap.LeadInTimeMS
	var lastTickTime:float = sixteenthBeatTimes.back()
	var lastTickPositionX:float = ((lastTickTime + (leadInMS)) * pixelsPerSecond)
	baseControl.custom_minimum_size.x = lastTickPositionX + 1920.0
	baseControl.size.x = lastTickPositionX + 1920.0

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
