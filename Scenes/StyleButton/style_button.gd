extends Button
class_name StyleButton

@export var panel:Panel
@export var font:FontVariation
@export var styleBoxFlat:StyleBoxFlat
@export var highlightColor:Color
@export_category("Animations")
@export_group("Highlight")
@export var highlightInTime:float = 0.1
@export var highlightOutTime:float = 0.5
func _on_resized() -> void:
	panel.size = size
