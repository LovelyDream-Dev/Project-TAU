extends Node2D
class_name HitObjectManager

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

var center:Vector2 = self.global_position

var editorSnapDivisor:int = 2
# TEMPORARY VALUE: The bpm of my test song
var bpm:float 
var secondsPerBeat:float
var beatsPerSecond:float
var mainSongPosition:float

# The amount of time in seconds a note spawns before its hit time
var spawnWindowInSeconds:float = 1.0
var beatsPerRotation:int = 4

## The index of the next hitObject to be spawned.
var nextHitObjectIndex:int = 0

func _ready() -> void:
	if CurrentMap.inEditor:
		radiusInPixels *= 0.5

func _process(_delta: float) -> void:
	bpm = CurrentMap.bpm
	secondsPerBeat = CurrentMap.secondsPerBeat
	beatsPerSecond = CurrentMap.beatsPerSecond
	mainSongPosition = CurrentMap.mainSongPosition
	if !CurrentMap.inEditor:
		if CurrentMap.mapStarted:
			spawn_gameplay_hit_objects(CurrentMap.hitObjects)
	else:
		spawn_editor_hit_objects(CurrentMap.hitObjects)

# --- CUSTOM FUNCTIONS ---

## Spawns hit objects during gameplay. See [member spawn_editor_hit_objects()] for spawning hit objects in the editor.
func spawn_gameplay_hit_objects(hitObjectArray:Array):
	while nextHitObjectIndex < hitObjectArray.size():
		var dict:Dictionary = hitObjectArray[nextHitObjectIndex]
		var hitTime:float = parse_hit_times(dict).hitTime
		var releaseTime:float = parse_hit_times(dict).releaseTime
		var side:int = parse_hit_times(dict).side
		var spawnTime:float = hitTime - spawnWindowInSeconds

		if CurrentMap.globalMapTimeInSeconds >= spawnTime:
			var hitBeat = hitTime * beatsPerSecond
			var angle = fmod(hitBeat, beatsPerRotation) * (TAU/beatsPerRotation)
			var spawnDistanceFromCenter = spawnSide * radiusInPixels * 2 * scrollSpeed
			var spawnPosition = get_position_along_radius(self.global_position, spawnDistanceFromCenter, spawnDirection * angle)
			var hitPosition = get_position_along_radius(self.global_position, spawnSide * radiusInPixels, spawnDirection * angle)

			var hitObject:HitObject = HitObject.new()
			var hitNoteTexture:Texture  = load("res://Default Skin/hit-note.png")
			var hitNoteOutlineTexture:Texture = load("res://Default Skin/hit-note-outline.png")
			hitObject.hitNoteTexture = hitNoteTexture
			hitObject.hitNoteOutlineTexture = hitNoteOutlineTexture
			hitObject.position = spawnPosition
			hitObject.spawnPosition = spawnPosition
			hitObject.hitPosition = hitPosition
			hitObject.center = self.global_position
			hitObject.spawnTime = spawnTime
			hitObject.hitTime = hitTime
			hitObject.releaseTime = releaseTime
			hitObject.side = side
			noteContainer.add_child(hitObject)
			CurrentMap.activeNotes.append(hitObject)
			nextHitObjectIndex += 1

## Spawns hit objects in the editor. See [member spawn_gameplay_hit_objects()] for spawning hit objects during gameplay.
func spawn_editor_hit_objects(hitObjectArray:Array):
	for dict in hitObjectArray:
		var hitTime:float = parse_hit_times(dict).hitTime 
		var spawnTime:float = hitTime - spawnWindowInSeconds
		if should_hit_object_be_spawned(hitTime, spawnTime):
			pass

func should_hit_object_be_spawned(hitTime:float, spawnTime:float) -> bool:
	var mapTime:float = CurrentMap.globalMapTimeInSeconds
	if (mapTime >= spawnTime) and (mapTime <= hitTime):
		return true
	return false

func get_beat_from_song_position(songPosition:float) -> float:
	return songPosition * beatsPerSecond

func parse_hit_times(dict:Dictionary):
	var ParsedHitObject = HitObjectParser.new()
	ParsedHitObject.hitTime = dict["hitTime"]
	ParsedHitObject.releaseTime = dict["releaseTime"]
	ParsedHitObject.side = dict["side"] 
	return ParsedHitObject

func get_position_along_radius(circleCenter:Vector2, circleRadius:float, angle:float):
	return circleCenter + Vector2(cos(angle), sin(angle)) * circleRadius
