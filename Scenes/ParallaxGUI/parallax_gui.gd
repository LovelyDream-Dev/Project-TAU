extends Control
class_name ParallaxGUI

@export var controls: Array[Control]
@export var maximumMovement: Vector2
@export var movementDecrease: float

var previousScreenPercent: Vector2 = Vector2(0,0)

func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	

func _process(_delta: float) -> void:
	initialize_controls()
	set_parallax(calculate_screen_percent(get_global_mouse_position()))

func calculate_screen_percent(globalPos: Vector2) -> Vector2 :
	var viewportSize = get_viewport_rect().size
	var p = globalPos/ viewportSize - Vector2(0.5,0.5)

	p.x = clamp(p.x, -0.5, 0.5)
	p.y =  clamp(p.y, -0.5, 0.5)
	return p

func set_parallax(screenPercent: Vector2) -> void:
	assert(controls.size() > 0, "Exported variable 'controls' has no members. ParallaxGUI")
	var move = maximumMovement
	for i in range(controls.size()):
		var c := controls[i]
		c.position = move * screenPercent
		move = move * movementDecrease
	previousScreenPercent = screenPercent

func _on_focus_changed(node: Control) -> void:	
	var p =calculate_screen_percent(node.global_position)
	var t = create_tween()
	t.tween_method(set_parallax, previousScreenPercent,  p, 0.25 )

func initialize_controls():
	for control:Control in controls:
		control.pivot_offset = Vector2(control.size/2)
		var mat:Material = control.material
		var blurShader:Shader = preload("res://Scripts/Shaders/simple_blur.gdshader")
		if mat != ShaderMaterial or mat.shader != blurShader:
			mat = ShaderMaterial.new()
			mat.shader = blurShader
