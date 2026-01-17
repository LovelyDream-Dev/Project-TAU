extends Node2D
class_name TimelineObjectContainer

@export var timeline:Timeline
var currentObjectIndex:int = 0
var sortedHitTimes:Array = []
var objectDict:Dictionary
var hitTime:float


func _ready() -> void:
	objectDict = CurrentMap.hitObjectDicts[currentObjectIndex]
	hitTime = objectDict["hitTime"]

func _process(_delta: float) -> void:
	#if !CurrentMap.mapStarted:
		#if !CurrentMap.MAP_TIME_CHANGED.is_connected(get_current_object_index):
			#CurrentMap.MAP_TIME_CHANGED.connect(get_current_object_index)
		#return
#
	#if CurrentMap.MAP_TIME_CHANGED.is_connected(get_current_object_index):
		#CurrentMap.MAP_TIME_CHANGED.disconnect(get_current_object_index)
	play_hitsounds()
  
func play_hitsounds():
	if CurrentMap.mapStarted:
		if currentObjectIndex < CurrentMap.hitObjectDicts.size():
			while CurrentMap.globalMapTimeInSeconds >= hitTime:
				print(currentObjectIndex)
				currentObjectIndex += 1
				objectDict = CurrentMap.hitObjectDicts[currentObjectIndex]
				hitTime = objectDict["hitTime"]
				MaestroSingleton.play_hitsound()
	else: 
		if CurrentMap.globalMapTimeInSeconds < hitTime and currentObjectIndex != 0:
			currentObjectIndex -= 1

#func play_hitsounds():
	#var objs:Array = get_children()
	#var obj:TimelineObject = objs[currentObjectIndex] if currentObjectIndex < get_child_count() else null
	#if obj == null:
		#return
	#var hitTime = obj.hitTime
	#while CurrentMap.globalMapTimeInSeconds >= hitTime and currentObjectIndex == obj.get_index():
		#currentObjectIndex += 1
		#MaestroSingleton.play_hitsound()
#
#func get_current_object_index(mapTime:float):
	#currentObjectIndex = Utils.find_nearest(mapTime, sortedHitTimes)["index"]
