extends Node2D

func _ready() -> void:
	CurrentMap.SPAWN_HIT_OBJECT.connect(spawn_hit_objects)

func spawn_hit_objects(hitObject:HitObject):
	self.add_child(hitObject)
