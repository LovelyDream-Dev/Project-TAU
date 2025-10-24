extends Node

var userAbsolutePath:String = OS.get_user_data_dir()
var playerData:PlayerData = PlayerData.new()
var mtween:MTween = MTween.new()

enum direction {
	LEFT = -1,
	RIGHT = 1
}

func side_from_raw(rawValue:int):
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
