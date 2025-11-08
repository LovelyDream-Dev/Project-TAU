extends Button
class_name StyleButton

@export_category("Animations")
@export_group("Highlight")
@export var highlightInTime:float = 0.1
@export var highlightOutTime:float = 0.25

var hovering:bool = false
var hoverTween:Tween

@onready var panel:Panel = $Panel

func _ready() -> void:
	if panel:
		if panel.has_theme_stylebox("panel"):
			panel.get_theme_stylebox("panel").duplicate(true)

func _process(_delta: float) -> void:
	if panel and panel.size != size:
		panel.size = size

	if !hovering and get_global_rect().has_point(get_global_mouse_position()):
		hovering = true
		hover_tween(1.0, highlightInTime)
	elif hovering and !get_global_rect().has_point(get_global_mouse_position()):
		hovering = false
		hover_tween(0.0, highlightOutTime)

func hover_tween(targetAlpha:Variant, duration:float):
	if hoverTween and hoverTween.is_running():
		hoverTween.kill()
	
	var currentAlpha = panel.modulate.a
	hoverTween = create_tween()
	hoverTween.tween_property(panel, "modulate:a", targetAlpha, duration).from(currentAlpha)
