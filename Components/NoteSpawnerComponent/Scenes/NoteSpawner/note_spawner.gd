extends Node2D
class_name NoteSpawner

## The color of the circle that notes are placed on in the editor
@export var circleColor:Color = Color("f44c4f")
	
@export var debugLine:bool = false

@export var minMouseDistance:float = 50.0

@export var radiusInPixels:float = 450.0


## The speed at which notes scroll
@export_range(0.8, 2.8, 0.1) var scrollSpeed:float = 1.0
## The side that notes begin spawning from. [br][br] [code]-1[/code]: Notes spawn from the left. [br][br] [code]1[/code]: Notes spawn from the right. 
@export_range(-1.0,1.0,2.0) var spawnSide:float = -1.0
## The direction, clockwise or counter-clockwise, that notes spawn in. [br][br][code]-1[/code]: Notes spawn counter-clockwise. br][br][code]1[/code]: Notes spawn clockwise.
@export_range(-1.0,1.0,2.0) var spawnDirection:float = 1.0
## The direction that notes are placed in. Used for when spin direction is changed while mapping. [br][br][code]-1[/code]: Beats along the circumference ascend counter-clockwise. [br][br][code]1[/code]: Beats along the circumference ascent clockwise.
@export_range(-1.0,1.0,2.0) var notePlacementDirection:float = 1.0
## The side that editor beats begin on. [br][br][code]0[/code]: The notes start on the right. [br][br][code]PI[/code]: The notes start on the left.
@export_range(0,PI,PI) var notePlacementSide:float = PI

@onready var editorFeatures:EditorFeatures = $EditorFeatures
@onready var noteContainer:Node2D = $NoteContainer

var editorSnapDivisor:int = 2
# TEMPORARY VALUE: The bpm of my test song
var bpm:float 
var secondsPerBeat:float
var beatsPerSecond:float
var mainSongPosition:float

var currentlySpawnedNotes:Array = []
# The amount of time in seconds a note spawns before its hit time
var spawnWindowInSeconds:float = 1.0
var beatsPerRotation:int = 4

func _process(_delta: float) -> void:
	bpm = CurrentMap.bpm
	secondsPerBeat = CurrentMap.secondsPerBeat
	beatsPerSecond = CurrentMap.beatsPerSecond
	mainSongPosition = CurrentMap.mainSongPosition
	if CurrentMap.mapStarted:
		spawn_notes()

# --- CUSTOM FUNCTIONS ---

func spawn_notes():
	for dict in CurrentMap.hitObjects:
		var startTime:float = parse_hit_times(dict).startTime
		var endTime:float = parse_hit_times(dict).endTime
		var side:int = parse_hit_times(dict).side
		# Check if the note hit time is within the spawn window and if the note is not already spawned
		if abs(mainSongPosition - startTime) < spawnWindowInSeconds and startTime not in currentlySpawnedNotes:
			# Calculate values needed for note spawning and set the values within the note
			var startBeat = startTime * beatsPerSecond
			var angle = fmod(startBeat, beatsPerRotation) * (TAU/beatsPerRotation)
			## This variable determines what side the notes spawn from, and the scroll speed.
			var spawnDistanceFromCenter = spawnSide * radiusInPixels * 2 * scrollSpeed
			var spawnPosition = get_position_along_radius(self.position, spawnDistanceFromCenter, spawnDirection * angle)
			var hitPosition = get_position_along_radius(self.position, spawnSide * radiusInPixels, spawnDirection * angle)

			var hitObject:HitObject = HitObject.new()
			var hitNoteTexture:Texture  = load("res://Default Skin/hit-note.png")
			var hitNoteOutlineTexture:Texture = load("res://Default Skin/hit-note-outline.png")
			hitObject.hitNoteTexture = hitNoteTexture
			hitObject.hitNoteOutlineTexture = hitNoteOutlineTexture

			hitObject.center = self.position
			hitObject.startTime = startTime
			hitObject.endTime = endTime
			hitObject.side = side
			hitObject.position = spawnPosition
			var tw = create_tween().set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_LINEAR).parallel()
			tw.tween_property(hitObject as HitObject, "position", hitPosition, startTime-mainSongPosition)
			noteContainer.add_child(hitObject)
			currentlySpawnedNotes.append(startTime)
			CurrentMap.activeNotes.append(hitObject)

func get_beat_from_song_position(songPosition:float) -> float:
	return songPosition * beatsPerSecond

func parse_hit_times(dict:Dictionary):
	var ParsedHitObject = HitObjectParser.new()
	ParsedHitObject.startTime = dict["startTime"]
	ParsedHitObject.endTime = dict["endTime"]
	ParsedHitObject.side = dict["side"] 
	return ParsedHitObject

func get_position_along_radius(circleCenter:Vector2, circleRadius:float, angle:float):
	return circleCenter + Vector2(cos(angle), sin(angle)) * circleRadius
