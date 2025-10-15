extends Node
class_name Maestro

signal WHOLE_BEAT
signal OFFSET_WHOLE_BEAT

@onready var metronome:AudioStreamPlayer = $Metronome
@onready var mainSong:AudioStreamPlayer = $MainSong
@onready var offsetSong:AudioStreamPlayer = $OffsetSong
@onready var editorOffsetSong:AudioStreamPlayer = $EditorOffsetSong
@onready var hitSound:AudioStreamPlayer = $HitSound

@export var timeline:Timeline
@export var metronomeIsOn:bool = false
@export var metronomeLeadInBeats:int

var polyphonicMetronome:AudioStreamPlaybackPolyphonic
var metronomeClick:AudioStream

var mainSongPosition:float
var offsetSongPosition:float

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

var mapFilePath:StringName

func _ready() -> void:
	metronomeClick = load("res://Audio Files/Metronome Click.wav")
	# MAP FILE NAME USED FOR _TESTING
	mapFilePath = "res://TestMaps/xaev for tau/"
	OFFSET_WHOLE_BEAT.connect(play_metronome)
	init_metronome()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("SPACE"):
		if !CurrentMap.mainSongIsPlaying and !CurrentMap.offsetSongIsPlaying:
			play_songs()
			CurrentMap.mapStarted = true
		else:
			pause_songs()
	

func _process(_delta: float) -> void:
	if !CurrentMap.mapLoaded:
		return

	leadInBeats = CurrentMap.leadInBeats
	leadInTime = CurrentMap.leadInTime
	secondsPerBeat = CurrentMap.secondsPerBeat
	beatsPerSecond = CurrentMap.beatsPerSecond

	if mainSong and mainSong.playing:
		mainSongPosition = mainSong.get_playback_position() 
		CurrentMap.mainSongPosition = mainSongPosition
		if CurrentMap.inEditor:
			CurrentMap.manualSongPosition = timeline.scrollContainer.scroll_horizontal / timeline.pixelsPerSecond
		emit_beat_signals()
	if offsetSong and offsetSong.playing: 
		offsetSongPosition = offsetSong.get_playback_position()
		CurrentMap.offsetSongPosition = offsetSongPosition
		emit_offset_beat_signals()

		CurrentMap.mainSongIsPlaying = mainSong.playing
		CurrentMap.offsetSongIsPlaying = offsetSong.playing

# --- CUSTOM FUNCTIONS ---

func play_songs():
	var isResuming := mainSongPosition > 0 or offsetSongPosition > 0
	if PlayerData.offsetInMs >= 0:
		# Positive offset: main (muted) starts immediately, audible starts later
		if !isResuming:
			mainSong.play()
			await get_tree().create_timer(PlayerData.offsetInMs/1000.0).timeout
			if mainSong.playing: 
				offsetSong.play()
		else:
			mainSong.play(mainSongPosition)
			offsetSong.play(max(mainSongPosition - (PlayerData.offsetInMs/1000.0), 0.0))
	else:
		# Negative offset: audible starts immediately, main (muted) starts later
		if !isResuming:
			offsetSong.play()
			await  get_tree().create_timer(-(PlayerData.offsetInMs/1000.0)).timeout
			if offsetSong.playing: mainSong.play()
		else: 
			offsetSong.play(offsetSongPosition)
			mainSong.play(max(offsetSongPosition + (PlayerData.offsetInMs/1000.0), 0.0))

func pause_songs():
	if mainSong.playing or offsetSong.playing:
		mainSongPosition = mainSong.get_playback_position()
		offsetSongPosition = offsetSong.get_playback_position()
		CurrentMap.mainSongPosition = mainSongPosition
		CurrentMap.offsetSongIsPlaying = offsetSongPosition
		mainSong.stop()
		offsetSong.stop()

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
			polyphonicMetronome.play_stream(metronomeClick, 0.0, 0.0, pitch)
