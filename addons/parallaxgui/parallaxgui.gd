@tool
extends EditorPlugin


func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	add_custom_type("ParallaxGUI", "Control", preload("res://addons/parallaxgui/parallaxgui.gd"), preload("res://addons/parallaxgui/Parallax2D.svg"))


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
