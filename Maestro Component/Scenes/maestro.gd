extends AudioStreamPlayer
class_name Maestro

signal WHOLE_BEAT
signal OFFSET_WHOLE_BEAT

var fileLoader = FileLoader.new()

@onready var mapData:MapDataContainer = $MapDataContainer
@onready var metronome:AudioStreamPlayer = $Metronome
@onready var mainSong:AudioStreamPlayer = $MainSong

@export var metronomeIsOn:bool = false
@export var metronomeLeadInBeats:int
@export var offsetInMs:float = 30.0

var polyphonicMetronome:AudioStreamPlaybackPolyphonic

var mapLoaded:bool

var offsetInSeconds:float

var mainSongPosition:float
var offsetSongPosition:float
var currentBPM:float

var currentMeasure:int
var beatsPerMeasure:int = 4

var lastWholeBeat:float = -1.0
var currentWholeBeat:float
var nextWholeBeat:float
var nextOffsetWholeBeat:float

var secondsPerBeat:float
var beatsPerSecond:float

var leadInTime:float
var leadInBeats:float

func _ready() -> void:
	OFFSET_WHOLE_BEAT.connect(play_metronome)
	init_metronome()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("SPACE") and mapLoaded:
		play_songs()
		pause_songs()
	if Input.is_action_just_pressed("ENTER"):
		mapData.select_audio_file_in_file_system()
		

func _process(_delta: float) -> void:
	mapLoaded = mapData.mapLoaded
	offsetInSeconds = offsetInMs/1000
	if !mapLoaded:
		fileLoader.load_map("res://Maestro Component/TestMap", mapData, self, mainSong)
		pass
	else:
		currentBPM = mapData.bpm
		secondsPerBeat = mapData.secondsPerBeat
		beatsPerSecond = mapData.beatsPerSecond
		leadInBeats = mapData.leadInBeats
		leadInTime = mapData.leadInTime
		currentBPM = mapData.bpm
		if mainSong.playing:
			mainSongPosition = mainSong.get_playback_position()
			emit_beat_signals()
		if self.playing: 
			offsetSongPosition = self.get_playback_position()
			emit_offset_beat_signals()

# --- CUSTOM FUNCTIONS ---


func play_songs():
	if offsetInMs >= 0:
		# Positive offset: main (muted) starts immediately, audible starts later
		if !mainSong.playing and mainSongPosition == 0.0:
			mainSong.play()
			await  get_tree().create_timer(offsetInSeconds).timeout
			if mainSong.playing: self.play()
		elif !mainSong.playing and mainSongPosition != 0.0:
			mainSong.play(mainSongPosition)
			self.play(max(mainSongPosition - offsetInSeconds, 0.0))
	else:
		# Negative offset: audible starts immediately, main (muted) starts later
		if !self.playing and offsetSongPosition == 0.0:
			self.play()
			await  get_tree().create_timer(-offsetInSeconds).timeout
			if self.playing: mainSong.play()
		elif !self.playing and offsetSongPosition != 0.0:
			self.play(offsetSongPosition)
			mainSong.play(max(mainSongPosition+offsetInSeconds, 0.0))

func pause_songs():
	if mainSong.playing and self.playing:
		mainSong.stop()
		self.stop()

func emit_beat_signals():
	currentWholeBeat = beatsPerSecond * mainSongPosition
	while mainSongPosition >= nextWholeBeat:
		var beatIndex = int(round(nextWholeBeat * beatsPerSecond))
		WHOLE_BEAT.emit(beatIndex)
		get_measure(beatIndex)
		nextWholeBeat += secondsPerBeat

func emit_offset_beat_signals():
	while offsetSongPosition >= nextOffsetWholeBeat:
		var beatIndex = int(round(nextOffsetWholeBeat * beatsPerSecond))
		OFFSET_WHOLE_BEAT.emit(beatIndex)
		nextOffsetWholeBeat += secondsPerBeat

func get_measure(beatIndex:int):
	if beatIndex % beatsPerMeasure == 0:
		currentMeasure = floor(currentWholeBeat) / beatsPerMeasure

func init_metronome():
	if metronome.stream == null or not(metronome.stream is AudioStreamPolyphonic):
		metronome.stream = AudioStreamPolyphonic.new()
	metronome.play()
	polyphonicMetronome = metronome.get_stream_playback()

func play_metronome(beatIndex:int):
	if metronomeIsOn:
		var offsetBeat:int = beatIndex - metronomeLeadInBeats
		if offsetBeat > -1:
			var pitch = 2.0 ** (2.0/12.0) if offsetBeat % 4 == 0 else 1.0
			var metronomeStream = load("res://Maestro Component/Audio Files/Metronome Click.wav")
			polyphonicMetronome.play_stream(metronomeStream, 0.0, 0.0, pitch)
