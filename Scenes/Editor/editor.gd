extends Control
class_name Editor

@export var timeline:Timeline
@export var spinner:Spinner
@export_category("LeftPanel")
@export_group("Buttons")

@export_category("RightPanel")
@export_group("Sliders")
@export var snapDivisorSlider:HSlider

var nextObjectIndex:int = 0
var nextObjectTime:float = CurrentMap.hitObjects[0]["hitTime"]
var defaultButtonColor:Color

var currentObjectIndex:int = 0
var objectsResnapped:bool = false

var objectMap:LinkMap = LinkMap.new()

func _enter_tree() -> void:
	EditorManager.linkMap.clear()
	MaestroSingleton.pause_songs()
	CurrentMap.globalMapTimeInSeconds = 0.0
	CurrentMap.mapIsPlaying = false
	var buttonStyleBox:StyleBoxFlat = preload("res://Resources/ButtonStyleBox.tres")
	defaultButtonColor = buttonStyleBox.bg_color
	CurrentMap.inEditor = true

func _ready() -> void:
	CurrentMap.radiusInPixels /= 2
	if !CurrentMap.is_map_loaded():
		FileLoader.load_map("user://maps/xaev for tau")

func _process(_delta: float) -> void:
	if CurrentMap.is_map_loaded() and timeline.timeline_objects_loaded() and !objectsResnapped:
		resnap_timeline_objects()
		objectsResnapped = true

	if snapDivisorSlider and !snapDivisorSlider.value_changed.is_connected(set_snap_divisor):
		snapDivisorSlider.value_changed.connect(set_snap_divisor)

	if !timeline.initialObjectOCull:
		timeline.initial_object_cull()
	get_object_pass()

func resnap_timeline_objects():
	for object:TimelineObject in timeline.timelineObjects:
		var snapInterval = CurrentMap.secondsPerBeat/EditorManager.editorSnapDivisor
		var time = object.hitTime
		var snappedTime = round(time/snapInterval) * snapInterval
		object.hitTime = snappedTime
		object.position.x = GlobalFunctions.get_timeline_position_x_from_seconds(snappedTime, timeline.pixelsPerSecond, timeline.playheadOffset)
		object.dragStartPosition.x = object.position.x

func set_snap_divisor(value):
	EditorManager.SNAP_DIVISOR_CHANGED.emit()
	match value:
		1.0:
			EditorManager.editorSnapDivisor = 1
			return
		2.0:
			EditorManager.editorSnapDivisor = 2
			return
		3.0:
			EditorManager.editorSnapDivisor = 4
			return
		4.0:
			EditorManager.editorSnapDivisor = 8
			return
		5.0:
			EditorManager.editorSnapDivisor = 16
			return

func get_object_pass() -> void:
	if !CurrentMap.mapIsPlaying:
		return
	while currentObjectIndex < CurrentMap.hitObjects.size() and CurrentMap.globalMapTimeInSeconds >= CurrentMap.hitObjects[currentObjectIndex]["hitTime"]:
		handle_object_pass(CurrentMap.hitObjects[currentObjectIndex]["hitTime"])
		currentObjectIndex += 1

func update_object_index():
	var left:int = 0
	var right:int = CurrentMap.hitObjects.size()

	while left < right:
		@warning_ignore("integer_division")
		var mid  = (left+right)/2
		if CurrentMap.hitObjects[mid] <= CurrentMap.globalMapTimeInSeconds:
			left = mid + 1
		else:
			right = mid
	

func handle_object_pass(_time:float):
	MaestroSingleton.play_hitsound()

func on_button_pressed(button:Button):
	match button.name:
		"Select":
			EditorManager.currentMode = EditorManager.modes.SELECT
		"Note":
			EditorManager.currentMode = EditorManager.modes.NOTE
		"HoldNote":
			EditorManager.currentMode = EditorManager.modes.HOLDNOTE
