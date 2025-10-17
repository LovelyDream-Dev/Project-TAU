extends Node
class_name FileSaver

func save_tau_data(filePath:String):
	var file = FileAccess.open(filePath, FileAccess.WRITE)
	if file == null:
		push_error("Could not open .tau file for writing: " + filePath)
		return

	file.store_line("[General]")
	file.store_line("AudioFileName: audio."+CurrentMap.audioFileExtension)
	file.store_line("LeadInBeats: "+ str(CurrentMap.leadInBeats))
	file.store_line("")
	file.store_line("[Metadata]")
	file.store_line("Title: "+CurrentMap.title)
	file.store_line("Artist: "+CurrentMap.artist)
	file.store_line("Creator: "+CurrentMap.creator)
	file.store_line("Version: "+CurrentMap.version)
	file.store_line("")
	file.store_line("[Difficulty]")
	file.store_line("HpDrainRate: "+str(CurrentMap.hpDrainRate))
	file.store_line("HitWindow: "+str(CurrentMap.hitWindow*1000))
	file.store_line("")
	file.store_line("[TimingPoints]")
	for tp:Dictionary in CurrentMap.timingPoints:
		file.store_line("time: "+str(tp["time"])+","+"bpm: "+ str(tp["bpm"]))
	file.store_line("")
	file.store_line("[HitObjects]")
	for obj:Dictionary in CurrentMap.hitObjects:
		file.store_line(str(obj["hitTime"])+","+str(obj["releaseTime"])+","+str(obj["side"]))
	
