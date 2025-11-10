extends Node
class_name ShapeArranger


static func circular_control_arrangement(controls:Array, center:Vector2, spacingInDegrees:float, startAngleInDegrees:float = 0, clockwise:bool = true) -> void:
	if controls.size() == 0:
		return

	var radStartAngle:float = deg_to_rad(startAngleInDegrees)
	var radSpacing:float = deg_to_rad(spacingInDegrees)
	for child:Control in controls:
		var firstChild:Control = controls[0]
		var index:int = child.get_index()
		child.pivot_offset = center
		firstChild.rotation = radStartAngle
		if child != firstChild:
			if clockwise:
				child.rotation = firstChild.rotation + (radSpacing * index)
			else:
				child.rotation = firstChild.rotation - (radSpacing * index)
