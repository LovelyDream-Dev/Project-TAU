extends Control
class_name ParallaxGUI


@export var parallaxStrngth:float = 0.5
@export var smoothness:float = 0.5
@export_category("Override")
@export var followMouse:bool = true

var targetOffset:Vector2 = Vector2.ZERO

func _process(_delta: float) -> void:
	move_children()

func move_children():
	var viewportSize = get_viewport_rect()
	if followMouse:
		for child in self.get_children():
			pass
