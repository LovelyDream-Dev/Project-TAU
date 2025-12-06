@tool
extends Button
class_name StyleButton

@export_category("Texture")
@export var texture:Texture

@export_category("Hover")
## The radius of the button that the mouse will need to be within to trigger the hover animation.
@export var hoverRadius:float = 0.0

@export_category("Animations")
@export_group("Highlight")
@export var highlightColor:Color = Color("ffffff00")
@export var enableHighlight:bool = true
@export var highlightInTime:float = 0.1
@export var highlightOutTime:float = 0.25
@export_group("Expand")
@export var enableExpand:bool = false
@export var expandInTime:float = 0.1
@export var expandOutTime:float = 0.1
@export_category("Functionality")
@export_group("Scene Change")
@export var sceneSwitch:bool = false
@export var scene:PackedScene = null

var hovering:bool = false
var hoverTween:Tween
var expandTween:Tween

var initialScale:Vector2

@onready var panel:Panel = $Panel
@onready var textureRect:TextureRect = $TextureRect

func _ready() -> void:
	if panel.has_theme_stylebox_override("panel"):
		panel.get_theme_stylebox("panel").bg_color = highlightColor
	pivot_offset = size/2
	initialScale = scale
	set_panel()

func _process(_delta: float) -> void:
	if texture and textureRect.texture != texture:
			set_texture()
			custom_minimum_size = textureRect.size
	if Engine.is_editor_hint():
		return
	if panel and panel.size != size:
		panel.size = size

	if hoverRadius == 0.0:
		if !hovering and get_global_rect().has_point(get_global_mouse_position()):
			hovering = true
			if enableHighlight:
				highlight_tween(1.0, highlightInTime)
			if enableExpand:
				expand_tween(Vector2(1.1, 1.1), expandInTime)
		elif hovering and !get_global_rect().has_point(get_global_mouse_position()):
			hovering = false
			if enableHighlight:
				highlight_tween(0.0, highlightOutTime)
			if enableExpand:
				expand_tween(Vector2(1.0, 1.0), expandOutTime)
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
	expandTween.tween_property(self, "scale", targetScale, duration).from(currentScale).set_trans(Tween.TRANS_BACK)

func hover_on_circle():
	var targetScaleUp:Vector2 = initialScale*1.1
	var distance = get_global_rect().get_center().distance_to(get_global_mouse_position())
	if hovering and distance < hoverRadius/2:
		hovering = false
		if enableHighlight:
			highlight_tween(1.0, highlightInTime)
		if enableExpand:
			expand_tween(targetScaleUp, expandInTime)
	elif !hovering and distance > hoverRadius/2:
		hovering = true
		if enableHighlight:
			highlight_tween(0.0, highlightOutTime)
		if enableExpand:
			expand_tween(initialScale, expandOutTime)

func set_panel():
	if panel:
		if panel.has_theme_stylebox("panel"):
			panel.get_theme_stylebox("panel").duplicate(true)

func set_texture():
	if texture:
		textureRect.texture = texture

func _on_pressed() -> void:
	if sceneSwitch and scene:
		get_tree().change_scene_to_file(scene.resource_path)
