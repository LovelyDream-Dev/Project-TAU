extends Control
class_name MainMenu

@export var parallax:ParallaxGUI

var _enableParallax:bool
@export var enableParallax:bool = true:
	set(value):
		if _enableParallax != value:
			_enableParallax = value
			toggle_parallax(value)
	get:
		return _enableParallax

func toggle_parallax(value):
	if parallax:
		if value == false:
			parallax.maximumMovement = Vector2.ZERO
		else:
			parallax.maximumMovement = Vector2(8.0, 8.0)
