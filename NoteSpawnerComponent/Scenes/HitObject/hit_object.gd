extends Node2D
class_name HitObject

var noteContainerParent:Node2D

var hitNoteTexture:Texture = null
var hitNoteOutlineTexture:Texture = null

## The ID of the hold note. If [member endBeat] is greater than [member startBeat], the note becomes a hold note.
var holdNoteID:int

## The time that the note is meant to be hit on. If it is less than [member endBeat], the note will be a hold note.
var startTime:float

## The time that the note is meant to be released on. If it is greater than [member startBeat], the note will be a hold note.
var endTime:float

## The side that the note is meant to be hit by. [br][code]-1[/code]: The note is hit by the left side. [br][code]1[/code]: The note is hit by the right side.
var side:int

## The center that the note will move towards and look at.
var center:Vector2

func _enter_tree() -> void:
	noteContainerParent = get_parent()
	var hitNote = Sprite2D.new()
	var hitNoteOutline = Sprite2D.new()
	hitNote.texture = hitNoteTexture
	hitNoteOutline.texture = hitNoteOutlineTexture
	
	if side == -1: hitNote.modulate = Color("924CF4")
	elif side == 1: hitNote.modulate = Color("F44C4F")
	
	self.add_child(hitNoteOutline)
	self.add_child(hitNote)
	self.look_at(center)

func set_hold_note():
	pass
