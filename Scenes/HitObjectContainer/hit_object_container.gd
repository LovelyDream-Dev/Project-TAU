extends Node2D

@export var timeline:Timeline

var manuallyScrolling:bool


func _enter_tree() -> void:
	CurrentMap.SPAWN_HIT_OBJECT.connect(spawn_hit_objects)

func _process(_delta: float) -> void:
	if timeline:
		manuallyScrolling = timeline.manuallyScrolling

# --- CUSTOM FUNCTIONS ---
func spawn_hit_objects(hitObject:HitObject):
	self.add_child(hitObject)
