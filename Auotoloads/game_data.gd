extends Node

var userAbsolutePath:String = OS.get_user_data_dir()

func _ready() -> void:
	# Creates the "user://maps" folder
	DirAccess.make_dir_absolute(userAbsolutePath.path_join("maps"))
