extends Node

var userAbsolutePath:String = OS.get_user_data_dir()
var mtween:MTween = MTween.new()

func _ready() -> void:
	FileLoader.load_user_config()
	# Create the "user://maps" folder
	DirAccess.make_dir_absolute(userAbsolutePath.path_join("maps"))
