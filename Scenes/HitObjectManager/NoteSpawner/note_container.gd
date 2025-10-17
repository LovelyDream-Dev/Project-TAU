extends Node2D

var parent:HitObjectManager 

var radiusInPixels:float

func _enter_tree() -> void:
	parent = get_parent()

func _process(_delta: float) -> void:
	radiusInPixels = parent.radiusInPixels
