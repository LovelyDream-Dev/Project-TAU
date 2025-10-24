extends Node

var userAbsolutePath:String = OS.get_user_data_dir()
var playerData:PlayerData = PlayerData.new()
var mtween:MTween = MTween.new()

enum direction {
	LEFT = -1,
	RIGHT = 1
}

## Returns a direction from an enum. [member direction.LEFT] if [member rawValue] is [code]-1[/code], or [member direction.RIGHT] if it is [code]1[/code]. 
## Returns [member direction.LEFT] if [member rawValue] is not [code]-1[/code] or [code]1[/code].
## Directions are used for various direction based mechanics.
func direction_from_raw(rawValue:int):
	if rawValue == -1:
		return direction.LEFT
	elif rawValue == 1:
		return direction.RIGHT
	else:
		push_error("Invalid side %s; defaulting to LEFT" % str(rawValue))
		return direction.LEFT

func _ready() -> void:
	# Create the "user://maps" folder
	DirAccess.make_dir_absolute(userAbsolutePath.path_join("maps"))
	DirAccess.make_dir_absolute(userAbsolutePath.path_join("data"))
