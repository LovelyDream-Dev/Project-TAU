extends Node2D
class_name Spinner

@onready var subRoot:Node2D = $SubRoot 
@onready var anchor:Node2D = $SubRoot/Anchor

# --- CURSORS ---
@onready var cursors:Node2D = $SubRoot/Anchor/Cursors
@onready var cursorLeft:Sprite2D = $SubRoot/Anchor/Cursors/CursorLeft
@onready var cursorRight:Sprite2D = $SubRoot/Anchor/Cursors/CursorRight

# --- HITRING ---
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
	cursorLeft.modulate = Color("924CF4")
	cursorRight.modulate = Color("F44C4F")
	CurrentMap.READY_TO_SPAWN_HIT_OBJECTS.connect(on_spinner_ready)
	rotationRadiansPerBeat = TAU * rotationsPerBeat

func _process(_delta: float) -> void:
	rotationRadiansPerSecond = rotationRadiansPerBeat / CurrentMap.secondsPerBeat
	bpm = CurrentMap.bpm
	secondsPerBeat = CurrentMap.secondsPerBeat
	beatsPerSecond = CurrentMap.beatsPerSecond
	if CurrentMap.mapLoaded:
		rotate_spinner()
		rotate_hit_ring()

# --- CUSTOM FUNCTIONS ---

## When [member CurrentMap] is ready to spawn hit notes on load time, this is called via signals to let [member CurrentMap] know the spinner is loaded. 
func on_spinner_ready():
	CurrentMap.center = global_position
	CurrentMap.spinnerLoaded = true

func rotate_spinner():
	anchor.rotation = rotationRadiansPerSecond *  CurrentMap.globalMapTimeInSeconds

func rotate_hit_ring():
	hitRing.rotation = (rotationRadiansPerSecond * CurrentMap.globalMapTimeInSeconds) * 0.1
