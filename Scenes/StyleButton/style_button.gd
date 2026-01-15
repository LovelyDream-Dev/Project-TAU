@tool
extends Button
class_name StyleButton

signal ENTER_HOVER
signal LEAVE_HOVER

@export var actionID:StringName
@export_category("Nodes")
@export var editor:Editor
@export_category("Texture")
@export var texture:Texture

@export_category("Hover")
## The radius of the button that the mouse will need to be within to trigger the hover animation.
@export var hoverRadius:float = 0.0
@export_category("Animations")
@export_group("Background")
@export var toggleBackground:bool = false
@export var backgroundColorRect:ColorRect
@export var backgroundColor:Color = Color.RED
@export_range(0.0, 1.0, 0.1) var maxAlpha:float = 1.0
@export_range(0.0, 1.0, 0.1) var minAlpha:float = 0.0
@export var fadetInTime:float = 0.1
@export var fadeOutTime:float = 0.25
@export_group("Highlight")
@export var highlightColor:Color = Color("96969689")
@export var enableHighlight:bool = true
@export var highlightInTime:float = 0.1
@export var highlightOutTime:float = 0.25
@export_group("Expand")
@export var enableExpand:bool = false
@export var expandInTime:float = 0.1
@export var expandOutTime:float = 0.1
@export_group("Easing")
@export var expandEase:Tween.EaseType = Tween.EASE_IN_OUT
@export_group("Transition")
@export var expandTransition:Tween.TransitionType = Tween.TRANS_BACK
@export_category("Functionality")
@export_group("Scene Change")
@export var sceneSwitch:bool = false
@export var scene:PackedScene = null

var hovering:bool = false
var hoverTween:Tween
var expandTween:Tween

var initialScale:Vector2

var bgTween:Tween

@onready var panel:Panel = $HighlightPanel
@onready var textureRect:TextureRect = $TextureRect

func _ready() -> void:
	if backgroundColorRect:
		backgroundColorRect.color = backgroundColor
		backgroundColorRect.color.a = minAlpha

	if panel.has_theme_stylebox_override("panel"):
		panel.get_theme_stylebox("panel").bg_color = highlightColor
	if panel.has_theme_stylebox("panel"):
			panel.get_theme_stylebox("panel").duplicate(true)

	initialScale = scale

	if editor:
		pressed.connect(editor.on_button_pressed.bind(actionID))

func _process(_delta: float) -> void:
	if texture and textureRect.texture != texture:
		set_texture()
		custom_minimum_size = textureRect.size

	pivot_offset = size/2
	size = textureRect.size
	panel.size = size
	panel.pivot_offset = panel.size/2
	textureRect.pivot_offset = textureRect.size/2

	if Engine.is_editor_hint():
		return

	# --- Hovering ---
	if hoverRadius == 0.0:
		normal_hover()
	else:
		hover_on_circle()

func highlight_tween(targetAlpha:float, duration:float):
	if hoverTween and hoverTween.is_running():
		hoverTween.kill()
	
	var currentAlpha = panel.modulate.a
	hoverTween = create_tween()
	hoverTween.tween_property(panel, "modulate:a", targetAlpha, duration).from(currentAlpha)

func expand_tween(targetScale:Vector2, duration:float):
	if expandTween and expandTween.is_running():
		expandTween.kill()
	
	var currentScale = self.scale
	expandTween = create_tween()
	expandTween.tween_property(self, "scale", targetScale, duration).from(currentScale).set_trans(expandTransition).set_ease(expandEase)

func normal_hover():
	if !hovering and get_global_rect().has_point(get_global_mouse_position()):
		ENTER_HOVER.emit()
		backgroundAnimation(true, bgTween)
		hovering = true
		if enableHighlight:
			highlight_tween(1.0, highlightInTime)
		if enableExpand:
			expand_tween(Vector2(1.1, 1.1), expandInTime)
	elif hovering and !get_global_rect().has_point(get_global_mouse_position()):
		LEAVE_HOVER.emit()
		backgroundAnimation(false, bgTween)
		hovering = false
		if enableHighlight:
			highlight_tween(0.0, highlightOutTime)
		if enableExpand:
			expand_tween(Vector2(1.0, 1.0), expandOutTime)

func hover_on_circle():
	var targetScaleUp:Vector2 = initialScale*1.1
	var distance = get_global_rect().get_center().distance_to(get_global_mouse_position())
	if hovering and distance < hoverRadius/2:
		hovering = false
		backgroundAnimation(false, bgTween)
		if enableHighlight:
			highlight_tween(1.0, highlightInTime)
		if enableExpand:
			expand_tween(targetScaleUp, expandInTime)
	elif !hovering and distance > hoverRadius/2:
		hovering = true
		backgroundAnimation(true, bgTween)
		if enableHighlight:
			highlight_tween(0.0, highlightOutTime)
		if enableExpand:
			expand_tween(initialScale, expandOutTime)

func backgroundAnimation(fadeIn:bool, bgt:Tween) -> void:
	if !backgroundColorRect:
		return

	var targetAlpha:float = maxAlpha if fadeIn else minAlpha
	var fadeTime = fadetInTime if fadeIn else fadeOutTime
	if bgt and bgt.is_running():
		bgt.kill()

	bgt = create_tween()
	bgt.tween_property(backgroundColorRect, "color:a", targetAlpha, fadeTime).from(backgroundColorRect.color.a)

func set_texture():
	if texture:
		textureRect.texture = texture

func _on_pressed() -> void:
	if toggle_mode == false:
		if sceneSwitch and scene:
			get_tree().change_scene_to_file(scene.resource_path)

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		highlight_tween(1.0, highlightInTime)
	else:
		highlight_tween(0.0, highlightOutTime)
