extends Node
class_name FileSaver

## Saves data to the user config file. If the file does not exist, it will be created.
static func save_user_config(path:StringName):
	var config = ConfigFile.new()
	print(path)
	# General
	config.set_value("General", "username", PlayerData.username)

	# Settings
	config.set_value("Settings", "color1", PlayerData.color1)
	config.set_value("Settings", "color2", PlayerData.color2)
	config.set_value("Settings", "scrollSpeed", PlayerData.scrollSpeed)
	config.set_value("Settings", "audioOffsetInMs", PlayerData.audioOffsetInMs)

	# Editor
	config.set_value("Editor", "editorSnapDivisor", PlayerData.editorSnapDivisor)

	# Save the file
	config.save(path)

static func save_tau_data(filePath:String):
	var file = FileAccess.open(filePath, FileAccess.WRITE)
	if file == null:
		push_error("Could not open .tau file for writing: " + filePath)
		return

	file.store_line("[General]")
	file.store_line("AudioFileName: audio."+CurrentMap.audioFileExtension)
	file.store_line("LeadInTimeMS: "+ str(CurrentMap.LeadInTimeMS))
	file.store_line("")
	file.store_line("[Metadata]")
	file.store_line("Title: "+CurrentMap.title)
	file.store_line("Artist: "+CurrentMap.artist)
	file.store_line("Creator: "+CurrentMap.creator)
	file.store_line("Version: "+CurrentMap.version)
	file.store_line("")
	file.store_line("[Difficulty]")
	file.store_line("HpDrainRate: "+str(CurrentMap.hpDrainRate))
	file.store_line("HitWindow: "+str(CurrentMap.hitWindowInSeconds))
	file.store_line("")
	file.store_line("[TimingPoints]")
	for tp:Dictionary in CurrentMap.timingPoints:
		file.store_line("time: "+str(tp["time"])+","+"bpm: "+ str(tp["bpm"]))
	file.store_line("")
	file.store_line("[HitObjects]")
	for vec3:Vector3 in EditorManager.linkMap.reverseMap.values():
		var objectDict:Dictionary = {"hitTime": vec3[0], "releaseTime": vec3[1], "side": vec3[2]}
		file.store_line(str(objectDict["hitTime"])+","+str(objectDict["releaseTime"])+","+str(objectDict["side"]))
	
