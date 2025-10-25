extends Control

@export var parent:TimelineObject

func _ready() -> void:
	self.position = parent.get_rect().position
	self.size = parent.get_rect().size

func _gui_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("LMB"):
		if EditorManager.currentMode == EditorManager.modes.SELECT:
			drag_object(Vector2(EditorManager.snappedPixel, EditorManager.yPos))

func drag_object(newPositon:Vector2):
	parent.position = newPositon
