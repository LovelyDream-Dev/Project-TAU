extends Node

var userAbsolutePath:String = OS.get_user_data_dir()
var playerData:PlayerData = PlayerData.new()
var mtween:MTween = MTween.new()

func _ready() -> void:
	# Create the "user://maps" folder
	DirAccess.make_dir_absolute(userAbsolutePath.path_join("maps"))
