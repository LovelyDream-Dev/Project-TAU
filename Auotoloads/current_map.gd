extends Node

signal READY_TO_SPAWN_HIT_OBJECTS
signal SPAWN_HIT_OBJECT

# --- MAP VARIABLES ---

var audioFilePath:StringName

var globalMapTimeInSeconds:float

var maestro:Maestro = MaestroSingleton

var inEditor:bool
var mapStarted:bool
var mapIsPlaying:bool
var mapFinished:bool

var activeObjects:Array = []
var hitObjects:Array = []
var timingPoints:Array = []
var rotationPoints:Array = []
var speedPoints:Array = []

var spawnedObjectCounter:int = 0
var songLengthInSeconds:float
var bpm:float = 120.0 # Default value
var secondsPerBeat:float = 0.0
var beatsPerSecond:float = 0.0
var mainSongPosition:float = 0.0
var offsetSongPosition:float = 0.0
var pixelsPerSecond:float = 0.0
var LeadInTimeMS:int = 0

var mainSongIsPlaying:bool
var offsetSongIsPlaying:bool
var editorMapInit:bool

var hpDrainRate:float = 0.0
var hitWindowInSeconds:float = 0.0

var tauFilePath:StringName
var title:String
var artist:String
var creator:String
var version:String
var audioFileExtension:String


var spinnerLoaded:bool
var center:Vector2
var spawnWindowInSeconds:float = 1.0
var beatsPerRotation:float = 4
var spawnSide:int = GlobalFunctions.side.LEFT
var rotationDirection:int = 1
var radiusInPixels
var scrollSpeed = PlayerData.scrollSpeed

func _ready() -> void:
	radiusInPixels = GameData.radiusInPixels
	InputManager.KEY_SPACE_PRESSED.connect(play_and_pause_map)

	if hitObjects.size() > 0:
		sort_hit_objects()
	if timingPoints.size() > 0:
		sort_timing_points()

func _process(delta: float) -> void:
	if !is_map_loaded():
		return

	timing_points()
	if !spinnerLoaded:
		READY_TO_SPAWN_HIT_OBJECTS.emit()
	else:
		spawn_hit_objects()

	mapStarted = maestro.songsPlaying
	mapFinished = globalMapTimeInSeconds >= MaestroSingleton.offsetSong.stream.get_length() + (PlayerData.audioOffsetInMs/1000.0)
	if mapStarted:
		globalMapTimeInSeconds += delta


func spawn_hit_objects(index:int = -1):
	if index == -1:
		if spawnedObjectCounter < hitObjects.size():
			SPAWN_HIT_OBJECT.emit(create_hit_object(hitObjects[spawnedObjectCounter]))
			sort_hit_objects()
			spawnedObjectCounter += 1
		elif spawnedObjectCounter > hitObjects.size():
			spawnedObjectCounter = hitObjects.size()
	else:
		SPAWN_HIT_OBJECT.emit(create_hit_object(hitObjects[index]))
		sort_hit_objects()
		spawnedObjectCounter += 1


func create_hit_object(dict:Dictionary) -> HitObject:
	var hitTime:float = GlobalFunctions.parse_hit_times(dict).hitTime
	var releaseTime:float = GlobalFunctions.parse_hit_times(dict).releaseTime
	var side:int = GlobalFunctions.parse_hit_times(dict).side
	var spawnTime:float = hitTime - spawnWindowInSeconds
	var hitBeat = hitTime * beatsPerSecond
	var angle = fmod(hitBeat, beatsPerRotation) * (TAU/beatsPerRotation)
	var spawnDistanceFromCenter = spawnSide * radiusInPixels * 2 * scrollSpeed
	var hitRadiusFromCenter = spawnSide * radiusInPixels
	var spawnPosition = GlobalFunctions.get_position_on_circumference(center, spawnDistanceFromCenter, rotationDirection * angle)
	var hitPosition = GlobalFunctions.get_position_on_circumference(center, hitRadiusFromCenter, rotationDirection * angle)
	var hitObject:HitObject = HitObject.new()
	var hitNoteTexture:Texture  = load("res://Skins/Default Skin/hit-note.png")
	var hitNoteOutlineTexture:Texture = load("res://Skins/Default Skin/hit-note-outline.png")
	hitObject.hitNoteTexture = hitNoteTexture
	hitObject.hitNoteOutlineTexture = hitNoteOutlineTexture
	hitObject.position = spawnPosition
	hitObject.spawnPosition = spawnPosition
	hitObject.hitPosition = hitPosition
	hitObject.spawnTime = spawnTime
	hitObject.hitTime = hitTime
	hitObject.releaseTime = releaseTime
	hitObject.side = GlobalFunctions.side_from_raw(side) 
	hitObject.objectDict = dict
	return hitObject

func play_and_pause_map(_mapTime = null):
	if !mapFinished:
		if !mapIsPlaying:
			maestro.play_songs()
			mapIsPlaying = true
		else:
			maestro.pause_songs()
			mapIsPlaying = false 

func on_songs_finished():
	if mapFinished and mapIsPlaying:
		mapIsPlaying = false
		maestro.pause_songs()
		globalMapTimeInSeconds = 0.0


# NEEDS FILEDIALOG "fileloaded" SIGNAL. CURRENTLY UNUSED
func handle_loaded_file(path:String):
	var ext := path.get_extension().to_lower()
	if ext not in ["mp3", "ogg"]:
		push_error("Unsupported audio format: " + ext)
		return

func timing_points():
	if len(timingPoints) == 0:
		return
	sort_timing_points()
	for tp in timingPoints:
		var time = tp["time"]
		var _bpm = tp["bpm"]
		if globalMapTimeInSeconds >= time:
			bpm = _bpm
			secondsPerBeat = 60.0/_bpm
			beatsPerSecond = _bpm/60.0

func sort_timing_points():
	if timingPoints.size() == 0:
		return

	timingPoints.sort_custom(func(a,b): 
		if a["time"] < b["time"]:
			return -1
		elif a["time"] > b["time"]:
			return 1
		else:
			return 0)

func sort_hit_objects():
	hitObjects.sort_custom(func(a,b): 
		if a["hitTime"] < b["hitTime"]:
			return -1
		elif a["hitTime"] > b["hitTime"]:
			return 1
		else:
			return 0)

func is_map_loaded():
	sort_timing_points()
	if !tauFilePath.is_empty():
		return true
	else: 
		return false


func unload_map():
	pixelsPerSecond = 0.0
	spawnedObjectCounter = 0
	mapStarted = false
	mapIsPlaying = false
	mapFinished = false
	activeObjects.clear()
	hitObjects.clear()
	timingPoints.clear()
	rotationPoints.clear()
	speedPoints.clear()
	bpm = 120.0 # Default value
	secondsPerBeat = 0.0
	beatsPerSecond = 0.0
	mainSongPosition = 0.0
	offsetSongPosition = 0.0
	LeadInTimeMS = 0
	mainSongIsPlaying = false
	offsetSongIsPlaying = false
	hpDrainRate = 0.0
	hitWindowInSeconds = 0.0
	tauFilePath = ""
	title = ""
	artist = ""
	creator = ""
	version = ""
	audioFileExtension = ""
	editorMapInit = false
