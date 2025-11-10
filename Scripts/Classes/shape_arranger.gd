extends Node
class_name ShapeArranger


static func circular_arrangement(nodes:Array, center:Vector2, radiusInPixels:float, spacingInDegrees:float, startAngleInDegrees:float = 0, clockwise:bool = true) -> void:
	if nodes.size() == 0:
		return

	var radStartAngle:float = deg_to_rad(startAngleInDegrees)
	var radSpacing:float = deg_to_rad(spacingInDegrees)
	for child in nodes:
		var x = cos(radStartAngle) * radiusInPixels
		var y = sin(radStartAngle) * radiusInPixels
		var pos = center + Vector2(x, y)
		if child is Control:
			child.position = pos - child.size/2
		else:
			child.position = pos
		if clockwise:
			radStartAngle += radSpacing
		else:
			radStartAngle -= radSpacing
