extends Sprite2D
class_name TimelineObject

var hitObjectSprite := Sprite2D.new() 

var hitObjectTexture:Texture = null

var leftColor:Color = Color("924CF4")
var rightColor = Color("F44C4F")
var highlightColor = Color("F6FF00")

var startPos:Vector2
var endPos:Vector2
var side:int

var hitObjectArray:Array = CurrentMap.hitObjects

var isSelected:bool:
	set(value):
		isSelected = value
		on_if_selected_changed(value)

# --- CUSTOM FUNCTIONS ---
func on_if_selected_changed(value):
	if value == true:
		self.add_to_group("selectedNotes")
		self.modulate = highlightColor
	else:
		self.remove_from_group("selectedNotes")
		self.modulate = Color(1, 1, 1, 1)
