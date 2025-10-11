extends Node2D
class_name Player_Spinner

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

# --- EXPORT VALUES ---
@export_category("Values")
@export var bpm:float = 120: 
	set(value):
		bpm = value
		on_bpm_changed(value)

# --- EXPORT STRINGS ---
@export_category("Strings")
## The string name of the custom input binding for key 1
@export var KEY1_INPUT_NAME:String
## The string name of the custom input binding for key 2
@export var KEY2_INPUT_NAME:String

var secondsPerBeat:float
var beatsPerSecond:float
var rotationRadiansPerBeat:float
## Fractional value of a rotation that happens in one beat
var rotationsPerBeat:float = 0.25

func _enter_tree() -> void:
	pass

func _ready() -> void:
	secondsPerBeat = 60/bpm
	beatsPerSecond = bpm/60
	rotationRadiansPerBeat = TAU * rotationsPerBeat

func _input(_event: InputEvent) -> void:
	hit_node_animations()
	body_animations()
	animate_lazers()

func _process(delta: float) -> void:
	rotate_spinner(delta)
	rotate_hit_rings(delta)

func _exit_tree() -> void:
	pass

# --- CUSTOM FUNCTIONS ---
func on_bpm_changed(value):
	secondsPerBeat = 60/value
	beatsPerSecond = value/60

func rotate_spinner(delta:float):
	anchor.rotation += rotationRadiansPerBeat  * (delta / secondsPerBeat)

func rotate_hit_rings(delta:float):
	outerRing.rotation += (rotationRadiansPerBeat/4)  * (delta / secondsPerBeat)
	hitRing.rotation += (rotationRadiansPerBeat/8)  * (delta / secondsPerBeat)

func animate_lazers():
	if Input.is_action_pressed(KEY1_INPUT_NAME):
		lazerLeft.activate_beam(true)
	if Input.is_action_just_released(KEY1_INPUT_NAME):
		lazerLeft.activate_beam(false)
	if Input.is_action_pressed(KEY2_INPUT_NAME):
		lazerRight.activate_beam(true)
	if Input.is_action_just_released(KEY2_INPUT_NAME):
		lazerRight.activate_beam(false)

func sparks():
	if Input.is_action_pressed(KEY1_INPUT_NAME):
		sparkLeft.emitting = true
	if Input.is_action_just_released(KEY1_INPUT_NAME):
		sparkLeft.emitting = false
	if Input.is_action_pressed(KEY2_INPUT_NAME):
		sparkRight.emitting = true
	if Input.is_action_just_released(KEY2_INPUT_NAME):
		sparkRight.emitting = false

# Init tween variables for hit node animations
var twLeftNode:Tween
var twRightNode:Tween

func hit_node_animations():
	# Key 1 press
	if Input.is_action_pressed(KEY1_INPUT_NAME):
		if twLeftNode and twLeftNode.is_running(): twLeftNode.kill()
		# Left node expand
		twLeftNode = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		twLeftNode.tween_property(hitNodeLeft, "scale", Vector2(1.2, 1.2), 0.05)

	# Key 1 release
	if Input.is_action_just_released(KEY1_INPUT_NAME):
		if twLeftNode and twLeftNode.is_running(): twLeftNode.kill()
		# Left node shrink
		twLeftNode = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		twLeftNode.tween_property(hitNodeLeft, "scale", Vector2(1.0, 1.0), 0.5)

	# Key 2 press
	if Input.is_action_pressed(KEY2_INPUT_NAME):
		if twRightNode and twRightNode.is_running(): twRightNode.kill()

		# Right node expand
		twRightNode = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		twRightNode.tween_property(hitNodeRight, "scale", Vector2(1.2, 1.2), 0.05)

	# Key 2 release
	if Input.is_action_just_released(KEY2_INPUT_NAME):
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
	if Input.is_action_pressed(KEY1_INPUT_NAME) or Input.is_action_pressed(KEY2_INPUT_NAME):
		if twBody and twBody.is_running(): twBody.kill()

		# Body Expand
		twBody = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		twBody.tween_property(body, "scale", Vector2(1.05, 1.05), 0.05)

	# Shader materials
	var matLeft = bodyFillLeft.material
	var matRight = bodyFillRight.material

	# Key 1 press
	if Input.is_action_just_pressed(KEY1_INPUT_NAME):
		if twLeftBody and twLeftBody.is_running(): twLeftBody.kill()

		# Body left flash
		twLeftBody = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		twLeftBody.tween_property(matLeft, "shader_parameter/brightness", 1.5, 0.05)

	# Key 1 release
	if Input.is_action_just_released(KEY1_INPUT_NAME):
		if twBody and twBody.is_running(): twBody.kill()
		if twLeftBody and twLeftBody.is_running(): twLeftBody.kill()

		# Body left dim
		twLeftBody = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		twLeftBody.tween_property(matLeft, "shader_parameter/brightness", 1.0, 0.1)

		# Body shrink 
		twBody = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		twBody.tween_property(body, "scale", Vector2(1.0, 1.0), 0.5)

	# Key 2 press
	if Input.is_action_just_pressed(KEY2_INPUT_NAME):
		if twRightBody and twRightBody.is_running(): twRightBody.kill()

		# Body right flash
		twRightBody = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		twRightBody.tween_property(matRight, "shader_parameter/brightness", 1.5, 0.05)

	# Key 2 release
	if Input.is_action_just_released(KEY2_INPUT_NAME):
		if twBody and twBody.is_running(): twBody.kill()
		if twRightBody and twRightBody.is_running(): twRightBody.kill()

		# Body right dim
		twRightBody = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		twRightBody.tween_property(matRight, "shader_parameter/brightness", 1.0, 0.1)

		# Body Shrink
		twBody = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		twBody.tween_property(body, "scale", Vector2(1.0, 1.0), 0.5)
