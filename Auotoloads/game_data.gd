extends Node

var userAbsolutePath:String = OS.get_user_data_dir()

const beatsPerRotation:int = 4
const spawnSide:int = -1
const radiusInPixels:float = 450.0

func _ready() -> void:
	FileLoader.load_user_config()
	# Create the "user://maps" folder
	DirAccess.make_dir_absolute(userAbsolutePath.path_join("maps"))
