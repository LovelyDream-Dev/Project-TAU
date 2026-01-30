extends Control
class_name Editor

@export var timeline:Timeline
@export var spinner:Spinner
@export var mapSetupPanel:Panel
@export var textEdits:Array[TextEdit]

var fileDialog:FileDialog = FileDialog.new()

var nextObjectIndex:int = 0
var nextObjectTime:float = 0.0
var defaultButtonColor:Color

var currentObjectIndex:int = 0
var objectsResnapped:bool = false

var objectMap:LinkMap = LinkMap.new()
var mapSetup:bool

func _enter_tree() -> void:
	EditorManager.linkMap.clear()
	MaestroSingleton.pause_songs()
	CurrentMap.globalMapTimeInSeconds = 0.0
	CurrentMap.mapIsPlaying = false
	var buttonStyleBox:StyleBoxFlat = preload("res://Resources/ButtonStyleBox.tres")
	defaultButtonColor = buttonStyleBox.bg_color
	#CurrentMap.inEditor = true

func _ready() -> void:
	if CurrentMap.hitObjectDicts.size() > 0: 
		nextObjectTime = CurrentMap.hitObjectDicts[0]["hitTime"]
	CurrentMap.radiusInPixels /= 2
	fileDialog.access = FileDialog.ACCESS_FILESYSTEM
	fileDialog.use_native_dialog = true
	fileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	fileDialog.add_filter("*.mp3, *.ogg", "Audio Files")
	add_child(fileDialog)

func _process(_delta: float) -> void:
	on_text_edit_text_set()
	# Load map
	if !CurrentMap.is_taumap_loaded():
		if CurrentMap.audioFilePath.is_empty(): 
			mapSetup = true
			fileDialog.file_selected.connect(func(path:String):
				CurrentMap.audioFilePath = path)
		else:
			var song := FileLoader.load_song(CurrentMap.audioFilePath)
			# This block runs on successful load # 
			if song is AudioStream:
				MaestroSingleton.mainSong.stream = song.duplicate()
				MaestroSingleton.offsetSong.stream = song.duplicate()
				CurrentMap.init_taumap()
				mapSetup = false
			else:
				push_error("Failed to load song. Song is not AudioStream")
	

	mapSetupPanel.visible = mapSetup
	if CurrentMap.is_taumap_loaded() and timeline.timeline_objects_loaded() and !objectsResnapped:
		resnap_timeline_objects()
		objectsResnapped = true

	if !timeline.initialObjectOCull:
		timeline.initial_object_cull()

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

func on_text_edit_text_set():
	for textEdit:TextEdit in textEdits:
		var text:String = textEdit.text
		match textEdit.name:
			"Title":
				if text.is_empty():
					return
				CurrentMap.title = text
			"Artist":
				if text.is_empty():
					return
				CurrentMap.artist = text
			"Creator":
				if text.is_empty():
					return
				CurrentMap.creator = text
			"Version":
				if text.is_empty():
					return
				CurrentMap.version = text
			"LeadInMs":
				if text.is_empty():
					return
				CurrentMap.LeadInTimeMS = int(text)
			"BPM":
				if text.is_empty():
					return
				CurrentMap.bpm = float(text)
			_:
				pass

func on_slider_value_changed(value:float, actionId:String):
	match actionId:
		"editorHpDrainRate":
			CurrentMap.hpDrainRate = value

func on_button_pressed(actionId:String):
	match actionId:
		"editorModeSelect":
			EditorManager.currentMode = EditorManager.modes.SELECT
		"editorModeNote":
			EditorManager.currentMode = EditorManager.modes.NOTE
		"editorModeHoldNote":
			EditorManager.currentMode = EditorManager.modes.HOLDNOTE
		"editorSideLeft":
			EditorManager.currentSide = EditorManager.sides.LEFT
		"editorSideRight":
			EditorManager.currentSide = EditorManager.sides.RIGHT
		"editorSaveMap":
			FileSaver.save_tau_data(CurrentMap.tauFilePath)
		"editorSelectAudioFile":
			fileDialog.popup_centered()
