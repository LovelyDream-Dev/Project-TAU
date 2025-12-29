extends Node2D

var stacks: = {}

func _ready() -> void:
	get_object_stacks()

func _process(_delta: float) -> void:
	stack_objects()
	queue_redraw()

func _draw() -> void:
	for object:TimelineObject in get_tree().get_nodes_in_group("selectedObjects"):
		draw_circle(object.position, object.texture.get_size().x/2, Color.WHITE, false, 5.0, true)

func get_object_stacks():
	for object:TimelineObject in get_children():
		var snappedTime:float = round(object.hitTime / EditorManager.editorSnapInterval) * EditorManager.editorSnapInterval
		var key = int(round(object.hitTime / snappedTime))
		if not stacks.has(key):
			stacks[key] = []
		stacks[key].append(object)

func stack_objects():
	for stack in stacks.values():
		if stack.size() <= 1:
			continue
		for i in stack.size():
			stack[i].position.y = EditorManager.localYPos - (i*10)
