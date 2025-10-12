extends Node

var mapStarted:bool

var activeNotes:Array = []
var hitObjects:Array = []
var timingPoints:Array = []
var rotationPoints:Array = []
var speedPoints:Array = []

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
