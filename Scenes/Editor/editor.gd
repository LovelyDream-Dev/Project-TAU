extends Control
class_name Editor

@export var timeline:Timeline
@export var spinner:Spinner
@export var snapDivisorSlider:HSlider

func _enter_tree() -> void:
	CurrentMap.inEditor = true

func _process(_delta: float) -> void:
	if snapDivisorSlider and !snapDivisorSlider.value_changed.is_connected(set_snap_divisor):
		snapDivisorSlider.value_changed.connect(set_snap_divisor)
	if !timeline.initialObjectOCull:
		timeline.initial_object_cull()

func set_snap_divisor(value):
	EditorManager.SNAP_DIVISOR_CHANGED.emit()
	match value:
		1.0:
			EditorManager.editorSnapDivisor = 1
			return
		2.0:
			EditorManager.editorSnapDivisor = 2
			return
		3.0:
			EditorManager.editorSnapDivisor = 4
			return
		4.0:
			EditorManager.editorSnapDivisor = 8
			return
		5.0:
			EditorManager.editorSnapDivisor = 16
			return
