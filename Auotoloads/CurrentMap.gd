extends Node

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
var offsetInMs:int

var mainSongIsPlaying:bool
var offsetSongIsPlaying:bool

var hpDrainRate:float = 0.0
var hitWindowInSeconds:float = 0.0

func clear_map():
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
	offsetInMs = 0
	mainSongIsPlaying = false
	offsetSongIsPlaying = false
	hpDrainRate = 0.0
	hitWindowInSeconds = 0.0
