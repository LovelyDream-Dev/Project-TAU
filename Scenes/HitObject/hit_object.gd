extends Node2D
class_name HitObject

var noteContainerParent:Node2D

var hitNoteTexture:Texture = null
var hitNoteOutlineTexture:Texture = null
var hitNote = Sprite2D.new()
var hitNoteOutline = Sprite2D.new()
var color:Color

var objectDict:Dictionary
var spawnPosition:Vector2
var hitPosition:Vector2
var spawnTime:float
var hitTime:float
var releaseTime:float
var side:int
var isDying:bool
var missed:bool

func _enter_tree() -> void:
	noteContainerParent = get_parent()
	hitNote.texture = hitNoteTexture
	hitNoteOutline.texture = hitNoteOutlineTexture
	if side == GlobalFunctions.side.LEFT: 
		color = PlayerData.color1
	elif side == GlobalFunctions.side.RIGHT: 
		color = PlayerData.color2
	add_child(hitNote)
	add_child(hitNoteOutline)

func _process(_delta: float) -> void:
	if spawnTime == null or hitTime == null:
		return

	manage_self_in_editor()

	if hitNote and hitNoteOutline:
		animate_self()
		is_active()

func manage_self_in_editor():
	if CurrentMap.inEditor:
		if objectDict not in CurrentMap.hitObjects:
			queue_free()

func animate_self():
	spawn_animation()
	hitAnimation()

func spawn_animation():
	# Position
	MTween.mtween_property(self, "global_position",spawnPosition, hitPosition, spawnTime, CurrentMap.spawnWindowInSeconds)
	# alpha modulate
	MTween.mtween_property(hitNote, "modulate",Color(color.r, color.g, color.b ,0), color, spawnTime, CurrentMap.spawnWindowInSeconds)
	MTween.mtween_property(hitNoteOutline, "modulate",Color(1,1,1,0), Color(1,1,1,1), spawnTime, CurrentMap.spawnWindowInSeconds)
	

func hitAnimation():
	MTween.mtween_property(self, "modulate", Color(1,1,1,1), Color(Color.GREEN, 0), hitTime, 0.5)

func is_active():
	if CurrentMap.globalMapTimeInSeconds <= spawnTime or CurrentMap.globalMapTimeInSeconds >= hitTime:
		CurrentMap.activeObjects.erase(self)
	else:
		CurrentMap.activeObjects.append(self)

func kill_note():
	isDying = true
	if !missed:
		var tw = create_tween().set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_LINEAR).parallel()
		tw.tween_property(self, "modulate", Color(Color.GREEN, 0), 0.5)
		CurrentMap.activeNotes.erase(self)
		await tw.finished
		queue_free()
	else: 
		var tw = create_tween().set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_LINEAR).parallel()
		tw.tween_property(self, "modulate", Color(Color.RED, 0), 0.5)
		CurrentMap.activeNotes.erase(self)
		await tw.finished
		queue_free()
