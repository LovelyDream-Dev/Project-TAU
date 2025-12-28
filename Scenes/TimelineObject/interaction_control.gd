extends Control

@export var parent:TimelineObject
@export var menu:MenuButton

func _ready() -> void:
	position = parent.get_rect().position
	size = parent.get_rect().size
	if menu:
		menu.size = parent.get_rect().size
		menu.get_popup().add_theme_stylebox_override("panel", create_popup_button_style())
		menu.get_popup().id_pressed.connect(on_popup_button_pressed)

#func _gui_input(_event: InputEvent) -> void:
	#if Input.is_action_pressed("LMB"):
		#if EditorManager.currentMode == EditorManager.modes.SELECT:
			#drag_object(Vector2(EditorManager.snappedPixel, EditorManager.localYPos))
#
#func drag_object(newPositon:Vector2):
	#parent.position = newPositon

func create_popup_button_style() -> StyleBoxFlat:
	var newStyle:StyleBoxFlat = StyleBoxFlat.new()
	newStyle.bg_color = Color("072031")
	newStyle.set_corner_radius_all(2)
	newStyle.set_border_width_all(2)
	if parent.side == GlobalFunctions.side.LEFT:
		newStyle.border_color = PlayerData.color1
	elif parent.side == GlobalFunctions.side.RIGHT:
		newStyle.border_color = PlayerData.color2
	return newStyle

func _on_menu_button_about_to_popup() -> void:
	menu.get_popup().position = get_rect().get_center()

func on_popup_button_pressed(id:int):
	if id == 0:
		parent.queue_free()
