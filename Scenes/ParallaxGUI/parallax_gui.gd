extends Control
class_name ParallaxGUI

@export var controls: Array[Control]
@export var maximumMovement: Vector2 = Vector2(8.0, 8.0)
@export var movementDecrease: float = 0.5

var previousScreenPercent: Vector2 = Vector2(0,0)

func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	

func _process(_delta: float) -> void:
	scale_controls()
	set_parallax(calculate_screen_percent(get_global_mouse_position()))

func calculate_screen_percent(globalPos: Vector2) -> Vector2 :
	var viewportSize = get_viewport_rect().size
	var p = globalPos/ viewportSize - Vector2(0.5,0.5)

	p.x = clamp(p.x, -0.5, 0.5)
	p.y =  clamp(p.y, -0.5, 0.5)
	return p

func set_parallax(screenPercent: Vector2) -> void:
	var move = maximumMovement
	if controls.size() == 0:
		assert(controls.size() > 0, "Exported variable 'controls' has no members. ParallaxGUI")
		return
	for i in range(controls.size()):
		var c := controls[i]
		c.position = move * screenPercent
		move = move * movementDecrease
	previousScreenPercent = screenPercent

func _on_focus_changed(node: Control) -> void:	
	var p =calculate_screen_percent(node.global_position)
	var t = create_tween()
	t.tween_method(set_parallax, previousScreenPercent,  p, 0.25 )

func scale_controls():
	for control:Control in controls:
		control.pivot_offset = Vector2(control.size/2)
