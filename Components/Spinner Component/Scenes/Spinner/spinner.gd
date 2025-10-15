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

# --- LAZERS ---
@onready var lazerLeft:Visual_Lazer = $SubRoot/Anchor/Lazers/LazerLeft
@onready var lazerRight:Visual_Lazer = $SubRoot/Anchor/Lazers/LazerRight

# --- SPARKS ---
@onready var sparkLeft:GPUParticles2D = $SubRoot/Anchor/Lazers/SparkLeft
@onready var sparkRight:GPUParticles2D = $SubRoot/Anchor/Lazers/SparkRight

# --- HITRING ---
@onready var outerRing:Node2D = $SubRoot/OuterRing
@onready var hitRing:Node2D = $SubRoot/HitRing

var maestro:Maestro = MaestroSingleton

var bpm:float
var secondsPerBeat:float
var beatsPerSecond:float
var rotationRadiansPerBeat:float
## Fractional value of a rotation that happens in one beat
var rotationsPerBeat:float = 0.25

func _ready() -> void:
	rotationRadiansPerBeat = TAU * rotationsPerBeat

func _input(_event: InputEvent) -> void:
	if CurrentMap.inEditor:
		return

	handle_input_timing()
	hit_node_animations()
	body_animations()
	animate_lazers()

func _process(delta: float) -> void:
	bpm = CurrentMap.bpm
	secondsPerBeat = CurrentMap.secondsPerBeat
	beatsPerSecond = CurrentMap.beatsPerSecond
	if CurrentMap.mainSongIsPlaying:
		rotate_spinner(delta)
		rotate_hit_rings(delta)

# --- CUSTOM FUNCTIONS ---

func handle_input_timing():
	var mainSongPosition = CurrentMap.mainSongPosition
	var hitWindowInSeconds = CurrentMap.hitWindowInSeconds
	# Handle hit logic only for the most recent note
	if CurrentMap.activeNotes.is_empty():
		return

	var currentNote: HitObject = CurrentMap.activeNotes.front()
	var startTime = currentNote.startTime

	if absf(mainSongPosition - startTime) < hitWindowInSeconds:
		if currentNote.side == -1 and Input.is_action_just_pressed("KEY1"):
			on_note_hit(currentNote)
		elif currentNote.side == 1 and Input.is_action_just_pressed("KEY2"):
			on_note_hit(currentNote)

	# Handle misses separately
	for hitObject:HitObject in CurrentMap.activeNotes.duplicate():
		var endTime = hitObject.endTime
		if mainSongPosition > endTime + hitWindowInSeconds and !hitObject.missed:
			hitObject.missed = true
			hitObject.kill_note()

func on_note_hit(hitObject:HitObject):
	hitObject.missed = false
	hitObject.kill_note()
	# Play the hitsound with offset compensation
	if CurrentMap.offsetInMs > 0:
		await get_tree().create_timer(CurrentMap.offsetInMs/1000.0).timeout
	maestro.hitSound.play()

func rotate_spinner(delta:float):
	anchor.rotation += rotationRadiansPerBeat  * (delta / secondsPerBeat)

func rotate_hit_rings(delta:float):
	outerRing.rotation += (rotationRadiansPerBeat/4)  * (delta / secondsPerBeat)
	hitRing.rotation += (rotationRadiansPerBeat/8)  * (delta / secondsPerBeat)

func animate_lazers():
	if Input.is_action_pressed("KEY1"):
		lazerLeft.activate_beam(true)
	if Input.is_action_just_released("KEY1"):
		lazerLeft.activate_beam(false)
	if Input.is_action_pressed("KEY2"):
		lazerRight.activate_beam(true)
	if Input.is_action_just_released("KEY2"):
		lazerRight.activate_beam(false)

func sparks():
	if Input.is_action_pressed("KEY1"):
		sparkLeft.emitting = true
	if Input.is_action_just_released("KEY1"):
		sparkLeft.emitting = false
	if Input.is_action_pressed("KEY2"):
		sparkRight.emitting = true
	if Input.is_action_just_released("KEY2"):
		sparkRight.emitting = false

# Init tween variables for hit node animations
var twLeftNode:Tween
var twRightNode:Tween

func hit_node_animations():
	# Key 1 press
	if Input.is_action_pressed("KEY1"):
		if twLeftNode and twLeftNode.is_running(): twLeftNode.kill()
		# Left node expand
		twLeftNode = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		twLeftNode.tween_property(hitNodeLeft, "scale", Vector2(1.2, 1.2), 0.05)

	# Key 1 release
	if Input.is_action_just_released("KEY1"):
		if twLeftNode and twLeftNode.is_running(): twLeftNode.kill()
		# Left node shrink
		twLeftNode = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		twLeftNode.tween_property(hitNodeLeft, "scale", Vector2(1.0, 1.0), 0.5)

	# Key 2 press
	if Input.is_action_pressed("KEY2"):
		if twRightNode and twRightNode.is_running(): twRightNode.kill()

		# Right node expand
		twRightNode = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		twRightNode.tween_property(hitNodeRight, "scale", Vector2(1.2, 1.2), 0.05)

	# Key 2 release
	if Input.is_action_just_released("KEY2"):
		if twRightNode and twRightNode.is_running(): twRightNode.kill()

		# Right node shrink
		twRightNode = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		twRightNode.tween_property(hitNodeRight, "scale", Vector2(1.0, 1.0), 0.5)

# Init tween variables for body animations
var twBody:Tween
var twLeftBody:Tween
var twRightBody:Tween

func body_animations():
	# Key 1 and key 2 press
	if Input.is_action_pressed("KEY1") or Input.is_action_pressed("KEY2"):
		if twBody and twBody.is_running(): twBody.kill()

		# Body Expand
		twBody = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		twBody.tween_property(body, "scale", Vector2(1.05, 1.05), 0.05)

	# Shader materials
	var matLeft = bodyFillLeft.material
	var matRight = bodyFillRight.material

	# Key 1 press
	if Input.is_action_just_pressed("KEY1"):
		if twLeftBody and twLeftBody.is_running(): twLeftBody.kill()

		# Body left flash
		twLeftBody = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		twLeftBody.tween_property(matLeft, "shader_parameter/brightness", 1.5, 0.05)

	# Key 1 release
	if Input.is_action_just_released("KEY1"):
		if twBody and twBody.is_running(): twBody.kill()
		if twLeftBody and twLeftBody.is_running(): twLeftBody.kill()

		# Body left dim
		twLeftBody = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		twLeftBody.tween_property(matLeft, "shader_parameter/brightness", 1.0, 0.1)

		# Body shrink 
		twBody = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		twBody.tween_property(body, "scale", Vector2(1.0, 1.0), 0.5)

	# Key 2 press
	if Input.is_action_just_pressed("KEY2"):
		if twRightBody and twRightBody.is_running(): twRightBody.kill()

		# Body right flash
		twRightBody = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		twRightBody.tween_property(matRight, "shader_parameter/brightness", 1.5, 0.05)

	# Key 2 release
	if Input.is_action_just_released("KEY2"):
		if twBody and twBody.is_running(): twBody.kill()
		if twRightBody and twRightBody.is_running(): twRightBody.kill()

		# Body right dim
		twRightBody = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		twRightBody.tween_property(matRight, "shader_parameter/brightness", 1.0, 0.1)

		# Body Shrink
		twBody = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		twBody.tween_property(body, "scale", Vector2(1.0, 1.0), 0.5)
