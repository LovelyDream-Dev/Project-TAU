extends Sprite2D
class_name TimelineObject

var lastObjectDict:Dictionary
var objectDict:Dictionary
var hitTime:float
var releaseTime:float
var isHoldNote:bool
var side:int

func _enter_tree() -> void:
	if releaseTime > hitTime:
		isHoldNote = true

func _ready() -> void:
	set_object_dict()

func _process(_delta: float) -> void:
	set_object_dict()
	manage_object()

func manage_object():
	if !objectDict.is_empty():
		if lastObjectDict in CurrentMap.hitObjects and objectDict not in CurrentMap.hitObjects:
			var index:int = CurrentMap.hitObjects.find(lastObjectDict)
			CurrentMap.hitObjects[index] = objectDict
			CurrentMap.spawn_hit_objects(index)
			lastObjectDict = objectDict

func set_object_dict():
	if !isHoldNote:
		hitTime = (position.x - EditorManager.playheadOffset) / CurrentMap.pixelsPerSecond
		releaseTime = hitTime
		objectDict = {"hitTime": hitTime, "releaseTime": releaseTime, "side": side}

func _exit_tree() -> void:
	CurrentMap.hitObjects.erase(objectDict)
