extends RefCounted
class_name LinkMap

var map:Dictionary = {}
var reverseMap:Dictionary = {}

func get_hashable(data:Dictionary) -> Vector3:
	return Vector3 (
		data.hitTime,
		data.releaseTime,
		data.side
	)

func add(obj:TimelineObject):
	var key := get_hashable(obj.objectDict)
	
	if not map.has(key):
		map[key] = []
	
	map[key].append(obj)
	reverseMap[obj] = key

func remove(obj:TimelineObject):
	if not reverseMap.has(obj):
		return
	var key:TimelineObject = reverseMap[obj]
	map[key].erase(obj)

	if map[key].is_empty():
		map.erase(key)
	
	reverseMap.erase(obj)

func update(obj:TimelineObject):
	var oldKey:Vector3 = reverseMap.get(obj)
	var newKey:Vector3 = get_hashable(obj.objectDict)

	if oldKey == newKey:
		return

	map[oldKey].erase(obj)
	if map[oldKey].is_empty():
		map.erase(oldKey)

	if not map.has(newKey):
		map[newKey] = []

	map[newKey].append(obj)
	reverseMap[obj] = newKey

func unregister(obj:TimelineObject):
	if not reverseMap.has(obj):
		return

	if obj.OBJECT_DICT_CHANGED.is_connected(update):
		obj.OBJECT_DICT_CHANGED.disconnect(update)

	var key = reverseMap[obj]
	map[key].erase(obj)

	if map[key].is_empty():
		map.erase(key)

	reverseMap.erase(obj)

func clear():
	map.clear()
