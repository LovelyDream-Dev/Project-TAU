extends Control
class_name MouseFunctions

@export var timeline:Timeline

@onready var cArea:Area2D = $Area2D
@onready var cShape:CollisionShape2D = $Area2D/CollisionShape2D

var mousePos:Vector2

# Drag Select
var dragSelectPos:Vector2
var dragSelectStarted:bool = false

# dragging
var dragging:bool
var dragStartPosX:float

func _input(_event: InputEvent) -> void:
	var timelineObjectsUnderMouse:Array[Dictionary] = get_collision_nodes_under_mouse(1)
	var firstTimelineObjectUnderMouse:TimelineObject
	if timelineObjectsUnderMouse.size() > 0:
		firstTimelineObjectUnderMouse = get_collision_nodes_under_mouse(1)[0]["collider"].get_parent()
	if Input.is_action_just_pressed("ESCAPE"):
		deselect_objects()

	if EditorManager.currentMode == EditorManager.modes.SELECT and (timeline.get_rect().has_point(mousePos) or (dragSelectStarted and get_tree().get_node_count_in_group("selectedObjects") > 0)):
		if Input.is_action_just_pressed("LMB"):
			if !dragSelectStarted and timelineObjectsUnderMouse.size() > 0:
				if !firstTimelineObjectUnderMouse.is_in_group("selectedObjects"):
					deselect_objects()
				firstTimelineObjectUnderMouse.add_to_group("selectedObjects")
				dragStartPosX = EditorManager.snappedPixel
				dragging = true
				resnap_objects()

		if Input.is_action_pressed("LMB"): 
			drag_objects()
			if !dragSelectStarted and !dragging and timelineObjectsUnderMouse.size() == 0:
				deselect_objects()
				var pos:Vector2 = mousePos
				dragSelectPos = Vector2(pos.x, EditorManager.globalYPos - 50)
				dragSelectStarted = true

		if Input.is_action_just_released("LMB"):
			dragging = false
	else:
		deselect_objects()
		dragging = false

func _process(_delta: float) -> void: 
	queue_redraw()
	mousePos = get_local_mouse_position()
	if timeline:
		size = timeline.size

	if EditorManager.currentMode == EditorManager.modes.SELECT:
		if !Input.is_action_pressed("LMB"):
			dragSelectStarted = false

		if !dragSelectStarted:
			cArea.process_mode = Node.PROCESS_MODE_DISABLED
			cShape.process_mode = Node.PROCESS_MODE_DISABLED
			cShape.shape.size = Vector2.ZERO
		else:
			cArea.process_mode = Node.PROCESS_MODE_ALWAYS
			cShape.process_mode = Node.PROCESS_MODE_ALWAYS
	else:
		cArea.process_mode = Node.PROCESS_MODE_DISABLED
		cShape.process_mode = Node.PROCESS_MODE_DISABLED

func _draw() -> void:
	if EditorManager.currentMode == EditorManager.modes.SELECT:
		if dragSelectStarted:
			draw_selection_rectangle()

func draw_selection_rectangle():
	var movingCorner = Vector2(mousePos.x - dragSelectPos.x, EditorManager.globalYPos + 25)
	var dragSelectionRect = Rect2(dragSelectPos, movingCorner)
	draw_rect(dragSelectionRect, Color(1.0, 1.0, 1.0, 0.337), true)
	cArea.position = dragSelectPos + (dragSelectionRect.size/2)
	cShape.shape.size = abs(dragSelectionRect.size)

func get_collision_nodes_under_mouse(collisionLayer:int = 1) -> Array[Dictionary]:
	var spaceState = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	query.collision_mask = collisionLayer
	var results = spaceState.intersect_point(query)
	return results

func deselect_objects():
	if get_tree().get_node_count_in_group("selectedObjects") > 0:
		for object:TimelineObject in get_tree().get_nodes_in_group("selectedObjects"):
			object.remove_from_group("selectedObjects")

func resnap_objects():
	for object:TimelineObject in get_tree().get_nodes_in_group("selectedObjects"):
		var snapCorrection:float = 1.0
		if EditorManager.snappedPixel > object.dragStartPosition.x:
			snapCorrection = fmod(EditorManager.snappedPixel, object.dragStartPosition.x)
			object.position.x += snapCorrection
			object.dragStartPosition.x = object.position.x
		else:
			snapCorrection = -fmod(object.dragStartPosition.x, EditorManager.snappedPixel)
			object.position.x += snapCorrection
			object.dragStartPosition.x = object.position.x

func drag_objects():
	if !dragging:
		return
	var snapDelta:float = EditorManager.snappedPixel - dragStartPosX
	for object:TimelineObject in get_tree().get_nodes_in_group("selectedObjects"):
		object.position.x = object.dragStartPosition.x + snapDelta 

func _on_area_2d_area_entered(area: Area2D) -> void:
	match area.name:
		"TimelineObjectArea":
			var object:TimelineObject = area.get_parent()
			object.add_to_group("selectedObjects")
		_:
			return
