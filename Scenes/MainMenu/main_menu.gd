extends Control
class_name MainMenu

@export var parallax:Parallax2D
@export var enableParallax:bool = true
@export var parallaxStrngth:float = 1.0

func _ready() -> void:
	if parallax:
		parallax.ignore_camera_scroll = true

func _process(_delta: float) -> void:
	get_relative_mouse_position_from_viewport_center()
	var mouseDistanceFromViewportCenter:float = get_viewport_rect().get_center().distance_to(get_global_mouse_position())
	parallax.scroll_offset = Vector2(mouseDistanceFromViewportCenter, mouseDistanceFromViewportCenter)

func get_relative_mouse_position_from_viewport_center():
	var viewportCenter:Vector2 = get_viewport_rect().get_center()
	var relativePosition = get_global_mouse_position() - viewportCenter

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
