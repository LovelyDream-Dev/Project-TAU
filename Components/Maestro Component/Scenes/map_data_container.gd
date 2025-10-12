extends Node
class_name MapDataContainer

@onready var fileDialog:FileDialog = $FileDialog

var fileLoader:FileLoader = FileLoader.new()
var fileSaver:FileSaver = FileSaver.new()

var parent:Maestro

var mapLoaded:bool = false
var newEditorMapInit:bool = false

var tauFilePath:String

var bpm:float = 0.0
var secondsPerBeat:float = 0.0
var beatsPerSecond:float = 0.0

var songLength:float = 0.0
var leadInBeats:float = 0.0
var leadInTime:float = 0.0

var hitObjects:Array = []
var timingPoints:Array = []

var audioFileExtension:String = ""
var title:String = ""
var artist:String = ""
var creator:String = ""
var version:String = ""

var hpDrainRate:float = 0.0
var hitWindowInSeconds:float = 0.0

func _ready() -> void:
	parent = get_parent()
	
	fileDialog.connect("file_selected", handle_loaded_file)

func _process(_delta: float) -> void:
	secondsPerBeat = 60/bpm
	beatsPerSecond = bpm/60
	CurrentMap.hitObjects = hitObjects
	CurrentMap.timingPoints = timingPoints
	CurrentMap.bpm = bpm
	CurrentMap.secondsPerBeat = secondsPerBeat
	CurrentMap.beatsPerSecond = beatsPerSecond
	CurrentMap.leadInBeats = leadInBeats
	CurrentMap.leadInTime = leadInTime
	CurrentMap.hitWindowInSeconds = hitWindowInSeconds
	CurrentMap.hpDrainRate = hpDrainRate
	timing_points()

# --- CUSTOM FUNCTIONS ---
func select_audio_file_in_file_system():
	fileDialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
	fileDialog.popup_centered()

func handle_loaded_file(path:String):
	var ext := path.get_extension().to_lower()
	if ext not in ["mp3", "ogg"]:
		push_error("Unsupported audio format: " + ext)
		return
	fileLoader.init_new_map(path, self, parent.offsetSong, parent.mainSong)

func timing_points():
	if len(timingPoints) == 0:
		return
	sort_timing_points()
	for tp in timingPoints:
		var time = tp["time"]
		var _bpm = tp["bpm"]
		if parent.offsetSong.get_playback_position() >= time:
			bpm = _bpm
			secondsPerBeat = 60.0/_bpm
			beatsPerSecond = _bpm/60.0
			leadInTime = beatsPerSecond * leadInBeats

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
		if a["start"] < b["start"]:
			return -1
		elif a["start"] > b["start"]:
			return 1
		else:
			return 0)

func unload_map():
	mapLoaded = false
	newEditorMapInit = false
	tauFilePath = ""
	songLength = 0.0
	leadInBeats = 0.0
	leadInTime = 0.0
	title = ""
	artist = ""
	creator = ""
	version = ""
	hpDrainRate = 0.0
	hitWindowInSeconds = 0.0
	hitObjects.clear()
	timingPoints.clear()
