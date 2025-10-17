extends Node

signal NOTE_HIT

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

func _ready() -> void:
	if hitObjects.size() > 0:
		sort_hit_objects()
	if timingPoints.size() > 0:
		sort_timing_points()

func _process(delta: float) -> void:
	if !mapLoaded:
		return

	if mapStarted:
		globalMapTimeInSeconds += delta
	
	timing_points()
	secondsPerBeat = 60/bpm
	beatsPerSecond = bpm/60

# --- CUSTOM FUNCTIONS ---

func start_map():
	maestro.play_songs()
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
		if maestro.offsetSong.get_playback_position() >= time:
			bpm = _bpm
			secondsPerBeat = 60.0/_bpm
			beatsPerSecond = _bpm/60.0
			leadInTime = secondsPerBeat * leadInBeats

func sort_timing_points():
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
