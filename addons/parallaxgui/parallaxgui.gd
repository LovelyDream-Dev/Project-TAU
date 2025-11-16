@tool
extends EditorPlugin


func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	add_custom_type("ParallaxGUI", "ParallaxGUI", preload("res://addons/parallaxgui/parallaxgui.gd"), preload("res://addons/parallaxgui/ParallaxGUI.svg"))


func _exit_tree() -> void:
	remove_custom_type("ParallaxGUI")
