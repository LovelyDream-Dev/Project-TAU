extends Sprite2D
class_name TimelineObject

signal OBJECT_DICT_CHANGED

var parent:TimelineObjectContainer

var lastObjectDict:Dictionary
var objectDict:Dictionary:
	set(value):
		objectDict = value
		OBJECT_DICT_CHANGED.emit()
var hitTime:float
var releaseTime:float
var isHoldNote:bool
var side:int

var dragStartPosition:Vector2

var selected:bool

func _enter_tree() -> void:
	if releaseTime > hitTime:
		isHoldNote = true

	parent  = get_parent()

	EditorManager.linkMap.add(self)
	OBJECT_DICT_CHANGED.connect(func(): EditorManager.linkMap.update(self))

func _exit_tree() -> void:
	EditorManager.linkMap.unregister(self)
	CurrentMap.hitObjects.erase(objectDict)

func _ready() -> void:
	set_object_dict()

func _process(_delta: float) -> void:
	if is_in_group("selectedObjects"):
		selected = true
		$HighlightManager.queue_redraw()
	elif !is_in_group("selectedObjects") and selected:
		$HighlightManager.queue_redraw()
		selected = false

	set_object_dict()
	manage_object()
	manage_stack()

func manage_object():
	if !objectDict.is_empty():
		if lastObjectDict in CurrentMap.hitObjects and objectDict not in CurrentMap.hitObjects:
			var index:int = CurrentMap.hitObjects.find(lastObjectDict)
			CurrentMap.hitObjects[index] = objectDict
			CurrentMap.spawn_hit_objects(index)
			lastObjectDict = objectDict

func manage_stack():
	var linkMap:LinkMap = EditorManager.linkMap
	var idx:int = linkMap.map[linkMap.get_hashable(objectDict)].find(self)
	var stackSize:int = linkMap.map[linkMap.get_hashable(objectDict)].size()
	z_index = stackSize - idx
	position.y = EditorManager.localYPos + (idx * 10)

func set_object_dict():
	if !isHoldNote:
		hitTime = (position.x - EditorManager.playheadOffset) / CurrentMap.pixelsPerSecond
		releaseTime = hitTime
		objectDict = {"hitTime": hitTime, "releaseTime": releaseTime, "side": side}
