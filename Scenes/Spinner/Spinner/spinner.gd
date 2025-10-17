extends Node2D
class_name Spinner

@onready var subRoot:Node2D = $SubRoot 
@onready var anchor:Node2D = $SubRoot/Anchor

# --- BODY ---
@onready var body:Node2D = $SubRoot/Anchor/Body
@onready var bodyFillLeft:Sprite2D = $SubRoot/Anchor/Body/BodyFillLeft
@onready var bodyFillRight:Sprite2D = $SubRoot/Anchor/Body/BodyFillRight

# --- HITNODES ---
@onready var hitNodes:Node2D = $SubRoot/Anchor/HitNodes
@onready var hitNodeLeft:Sprite2D = $SubRoot/Anchor/HitNodes/HitNodeLeft
@onready var hitNodeRight:Sprite2D = $SubRoot/Anchor/HitNodes/HitNodeRight

# --- CURSORS ---
@onready var cursors:Node2D = $SubRoot/Anchor/Cursors
@onready var cursorLeft:Sprite2D = $SubRoot/Anchor/Cursors/CursorLeft
@onready var cursorRight:Sprite2D = $SubRoot/Anchor/Cursors/CursorRight

# --- HITRING ---
@onready var outerRing:Node2D = $SubRoot/OuterRing
@onready var hitRing:Node2D = $SubRoot/HitRing

var maestro:Maestro = MaestroSingleton

var bpm:float
var secondsPerBeat:float
var beatsPerSecond:float
var rotationRadiansPerBeat:float
var rotationRadiansPerSecond:float
## Fractional value of a rotation that happens in one beat
var rotationsPerBeat:float = 0.25

func _ready() -> void:
	rotationRadiansPerBeat = TAU * rotationsPerBeat

func _process(_delta: float) -> void:
	rotationRadiansPerSecond = rotationRadiansPerBeat / CurrentMap.secondsPerBeat
	bpm = CurrentMap.bpm
	secondsPerBeat = CurrentMap.secondsPerBeat
	beatsPerSecond = CurrentMap.beatsPerSecond
	if !CurrentMap.inEditor:
		if CurrentMap.mainSongIsPlaying:
			rotate_spinner()
			rotate_hit_rings()
	else:
		#rotate_spinner()
		rotate_hit_rings()

# --- CUSTOM FUNCTIONS ---

func rotate_spinner():
	anchor.rotation = rotationRadiansPerSecond * CurrentMap.globalMapTimeInSeconds

func rotate_hit_rings():
	outerRing.rotation = (rotationRadiansPerSecond * CurrentMap.globalMapTimeInSeconds) * -1 * 0.5
	hitRing.rotation = (rotationRadiansPerSecond * CurrentMap.globalMapTimeInSeconds) * 0.5
