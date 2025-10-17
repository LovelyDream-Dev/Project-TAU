extends Node
class_name MTween


func mtween_property(target:Object, property:StringName, endValue, startTime:float, duration:float):
	var startValue = target.get(property)
	var globalTime:float = CurrentMap.globalMapTimeInSeconds
	var progress:float = clampf((globalTime - startTime) / duration, 0.0, 1.0)
	var currentValue
	match typeof(startValue):
		TYPE_VECTOR2:
			currentValue = startValue.lerp(endValue, progress)
		TYPE_VECTOR3:
			currentValue = startValue.lerp(endValue, progress)
		TYPE_COLOR:
			currentValue = startValue.lerp(endValue, progress)
		_:
			currentValue = lerp(startValue, endValue, progress)

	target.set(property, currentValue)
