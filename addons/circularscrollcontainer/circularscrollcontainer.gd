@tool
extends EditorPlugin


func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	add_custom_type("CircularScrollContainer", "Control", preload("res://Scenes/CircularScrollContainer/circular_scroll_container.gd"), preload("res://icon.svg"))


func _exit_tree() -> void:
	remove_custom_type("CircularScrollContainer")
