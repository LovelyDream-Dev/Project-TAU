extends Control

@export var pivot: Control
@export var radius: float = 500.0
@export var spacingMultiplier: float = .2 # >1 = more space between nodes, <1 = less
@export var rotationOffset: float = 0.0     # rotates the whole circle

func _ready() -> void:
	arrange_children_in_a_circle()

func arrange_children_in_a_circle():
	var children = pivot.get_children()
	var count = children.size()
	if count == 0:
		return

	var center: Vector2 = pivot.get_rect().get_center() * 0.5
	var angleStep: float = 360.0 / count * spacingMultiplier

	for i in range(count):
		var angleDeg = i * angleStep + rotationOffset
		var angleRad = deg_to_rad(angleDeg)
		var pos = Vector2(cos(angleRad), sin(angleRad)) * radius + center
		children[i].position = pos
