extends Node

signal SPAWN_HIT_OBJECT

var fileLoader = FileLoader.new()

# --- MAP VARIABLES ---

var globalMapTimeInSeconds:float

var maestro:Maestro = MaestroSingleton

var inEditor:bool 
var mapLoaded:bool
var mapStarted:bool

var activeNotes:Array = []
var hitObjects:Array = []
var timingPoints:Array = []
var rotationPoints:Array = []
var speedPoints:Array = []

var songLengthInSeconds:float
var bpm:float = 0.0
var secondsPerBeat:float = 0.0
var beatsPerSecond:float = 0.0
var mainSongPosition:float = 0.0
var offsetSongPosition:float = 0.0
var leadInBeats:float = 0.0
var leadInTime:float = 0.0

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

# --- HIT OBJECT VARIABLES ---
var center:Vector2
var spawnWindowInSeconds:float = 1.0
var beatsPerRotation:float = 4
var spawnSide:int = -1
var rotationDirection:int = 1
var radiusInPixels = 450.0
var scrollSpeed = GameData.playerData.scrollSpeed
var spawnedNotes:Array = []


func _ready() -> void:
	if hitObjects.size() > 0:
		sort_hit_objects()
	if timingPoints.size() > 0:
		sort_timing_points()

func _process(delta: float) -> void:
	if !is_map_loaded():
		var path = "user://maps/xaev for tau"
		fileLoader.load_map(path)
		timing_points()
		secondsPerBeat = 60/bpm
		beatsPerSecond = bpm/60
		for dict in hitObjects:
			spawn_hit_object(dict)
		return

	if !mapLoaded: mapLoaded = true 

	if mapStarted:
		globalMapTimeInSeconds += delta
	
	
	

# --- CUSTOM FUNCTIONS ---

func spawn_hit_object(dict:Dictionary):
	var hitTime:float = parse_hit_times(dict).hitTime
	var releaseTime:float = parse_hit_times(dict).releaseTime
	var side:int = parse_hit_times(dict).side
	var spawnTime:float = hitTime - spawnWindowInSeconds

	var hitBeat = hitTime * beatsPerSecond
	var angle = fmod(hitBeat, beatsPerRotation) * (TAU/beatsPerRotation)
	var spawnDistanceFromCenter = spawnSide * radiusInPixels * 2 * scrollSpeed
	var spawnPosition = get_position_along_circumference(center, spawnDistanceFromCenter, rotationDirection * angle)
	var hitPosition = get_position_along_circumference(center, spawnSide * radiusInPixels, rotationDirection * angle)

	var hitObject:HitObject = HitObject.new()
	var hitNoteTexture:Texture  = load("res://Skins/Default Skin/hit-note.png")
	var hitNoteOutlineTexture:Texture = load("res://Skins/Default Skin/hit-note-outline.png")
	hitObject.hitNoteTexture = hitNoteTexture
	hitObject.hitNoteOutlineTexture = hitNoteOutlineTexture
	hitObject.position = spawnPosition
	hitObject.spawnPosition = spawnPosition
	hitObject.hitPosition = hitPosition
	hitObject.center = center
	hitObject.spawnTime = spawnTime
	hitObject.hitTime = hitTime
	hitObject.releaseTime = releaseTime
	hitObject.side = side
	SPAWN_HIT_OBJECT.emit(hitObject)

func get_beat_from_song_position(songPosition:float) -> float:
	return songPosition * beatsPerSecond

func parse_hit_times(dict:Dictionary):
	var ParsedHitObject = HitObjectParser.new()
	ParsedHitObject.hitTime = dict["hitTime"]
	ParsedHitObject.releaseTime = dict["releaseTime"]
	ParsedHitObject.side = dict["side"] 
	return ParsedHitObject

func get_position_along_circumference(circleCenter:Vector2, circleRadius:float, angle:float):
	return circleCenter + Vector2(cos(angle), sin(angle)) * circleRadius

func start_map():
	#maestro.play_songs()
	mapStarted = true

func stop_map():
	maestro.pause_songs()
	mapStarted = false

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
		leadInTime = leadInBeats * secondsPerBeat

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
		if a["startTime"] < b["startTime"]:
			return -1
		elif a["startTime"] > b["startTime"]:
			return 1
		else:
			return 0)

func is_map_loaded():
	sort_timing_points()
	if songLengthInSeconds > 0.0 and timingPoints[0]["bpm"] > 0.0:
		return true
	else: 
		return false


func unload_map():
	mapLoaded = false
	mapStarted = false
	activeNotes.clear()
	hitObjects.clear()
	timingPoints.clear()
	rotationPoints.clear()
	speedPoints.clear()
	bpm = 0.0
	secondsPerBeat = 0.0
	beatsPerSecond = 0.0
	mainSongPosition = 0.0
	offsetSongPosition = 0.0
	leadInBeats = 0.0
	leadInTime = 0.0
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
