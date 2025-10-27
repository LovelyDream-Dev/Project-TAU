extends Control
class_name Editor

@export var timeline:Timeline
@export var spinner:Spinner
@export_category("LeftPanel")
@export_group("Buttons")
@export var selectButton:Button
@export var noteButon:Button
@export var holdNoteButton:Button
@export_category("RightPanel")
@export_group("Sliders")
@export var snapDivisorSlider:HSlider

var defaultButtonColor:Color

func _enter_tree() -> void:
	var buttonStyleBox:StyleBoxFlat = preload("res://Resources/ButtonStyleBox.tres")
	defaultButtonColor = buttonStyleBox.bg_color
	CurrentMap.inEditor = true

func _ready() -> void:
	connect_buttons()


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


func on_button_pressed(id:int, _button:Button):
	match id:
		EditorManager.modes.SELECT:
			EditorManager.currentMode = EditorManager.modes.SELECT

func connect_buttons():
	var id:int = 0
	for button:Button in [selectButton, noteButon, holdNoteButton]:
		button.pressed.connect(on_button_pressed.bind(id, button))
		id += 1
