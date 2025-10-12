extends Node
class_name FileLoader

var fileSaver:FileSaver = FileSaver.new()

var originalAudioFileName:String
var mapFolderPath:String
var AudioFileExtension:String

func load_map(folderPath:String, mapData:MapDataContainer, offsetSong:AudioStreamPlayer, mainSong:AudioStreamPlayer):
	mapData.unload_map()
	var dir = DirAccess.open(folderPath)
	if dir == null:
		push_error("Could not open folder: "+folderPath)
		return

	dir.list_dir_begin()
	var fileName = dir.get_next()
	while fileName != "": # if there are no more files, filename will be ""
		if not dir.current_is_dir():
			if fileName.ends_with(".tau"):
				mapData.tauFilePath = folderPath.path_join(fileName)
				load_tau_file(mapData.tauFilePath, folderPath, mapData, offsetSong, mainSong)
		fileName = dir.get_next()
	dir.list_dir_end()
	mapData.mapLoaded = true

func load_tau_file(filePath:String, folderPath:String, mapData:MapDataContainer, audioPlayer:AudioStreamPlayer, mainSong:AudioStreamPlayer):
	var file = FileAccess.open(filePath, FileAccess.READ)
	if file == null:
		push_error("Could not open .tau file: "+filePath)
		return

	var inGeneral = false
	var inMetadata = false
	var inDifficulty = false
	var inTimingPoints = false
	var inHitObjects = false
	while not file.eof_reached():
		var line:String = file.get_line().strip_edges()
		if line == "" or line.begins_with("#"): # Skip empty or commented lines
			continue

		if line.begins_with("[") and line.ends_with("]"):
			inHitObjects = (line == "[HitObjects]")
			inTimingPoints = (line == "[TimingPoints]")
			inGeneral = (line == "[General]")
			inMetadata = (line == "[Metadata]")
			inDifficulty = (line == "[Difficulty]")
			continue

		if inGeneral:
			if line.begins_with("AudioFileName:"):
				var parts = line.split(":", false, 1) # split into [ "AudioFileName", " song.mp3" ]
				var audioFilePath = folderPath.path_join(parts[1].strip_edges())
				load_song(audioFilePath, mapData, audioPlayer, mainSong)
			elif line.begins_with("LeadInBeats:"):
				var parts = line.split(":", false, 1) # split into [ "LeadInBeats", value]
				mapData.leadInBeats = float(parts[1])

		if inMetadata:
			if line.begins_with("Title:"):
				var parts = line.split(":", false, 1)
				mapData.title = parts[1].strip_edges()
			elif line.begins_with("Artist:"):
				var parts = line.split(":", false, 1)
				mapData.artist = parts[1].strip_edges()
			elif line.begins_with("Creator:"):
				var parts = line.split(":", false, 1)
				mapData.creator = parts[1].strip_edges()
			elif line.begins_with("Version:"):
				var parts = line.split(":", false, 1)
				mapData.version = parts[1].strip_edges()

		if inDifficulty:
			if line.begins_with("HpDrainRate:"):
				var parts = line.split(":", false, 1)
				mapData.hpDrainRate = float(parts[1])
			if line.begins_with("HitWindow:"):
				var parts = line.split(":", false, 1)
				mapData.hitWindowInSeconds = float(parts[1])/1000

		# Format for timing points in the tau file: "bpm: value, time: value"
		# Format for timing points as a dictionary: {"bpm" : value, "time" : value} 
		if inTimingPoints:
			var parts = line.split(",")
			if parts.size() == 2:
				var timingPoint = {
					"bpm": float(parts[0].substr(4).strip_edges()),
					"time": float(parts[1].substr(5).strip_edges())
				}
				mapData.timingPoints.append(timingPoint)

		# Format for hit objects in the tau file: "Note start, Note end, Note type"
		# Note type 0 is left and note type 1 is right
		# Format for hit objects as a dictionary: {"start" : value, "end" : value, "type": value}
		if inHitObjects:
			var parts = line.split(",")
			if parts.size() == 3:
				var hitObject = {
					"startTime": float(parts[0].strip_edges()),
					"endTime": float(parts[1].strip_edges()),
					"side": int(parts[2].strip_edges())
				}
				mapData.hitObjects.append(hitObject)

func init_new_map(songFilePath:String, mapData:MapDataContainer, offsetSong:AudioStreamPlayer, mainSong:AudioStreamPlayer):
	originalAudioFileName = songFilePath.get_file().get_basename()
	AudioFileExtension = songFilePath.get_file().get_extension()

	mapData.audioFileExtension = AudioFileExtension.to_lower()

	load_song(songFilePath, mapData, offsetSong, mainSong)

	var userPath:String = "D:/Users/Teren/Godot Projects/Rhythm Maestro/Maestro Component"
	mapFolderPath = userPath.path_join(originalAudioFileName+AudioFileExtension.to_lower())

	var errFolder := DirAccess.make_dir_absolute(mapFolderPath)
	if errFolder != OK:
		if ERR_ALREADY_EXISTS:
			push_error("Couldn't create map folder at: "+mapFolderPath+". "+"Folder already exists.")
		else:
			push_error("Couldn't create map folder at: "+mapFolderPath+".")
		return

	var newAudioFilePath = mapFolderPath.path_join("audio."+AudioFileExtension.to_lower())
	var errFile := DirAccess.copy_absolute(songFilePath, newAudioFilePath)
	if errFile != OK:
		if ERR_ALREADY_EXISTS:
				push_error("Couldn't copy audio file from: "+songFilePath+" to: "+newAudioFilePath+". "+"File already exists.")
		else:
			push_error("Couldn't copy audio file from: "+songFilePath+" to: "+newAudioFilePath+".")
		return

	var tauFilePath = mapFolderPath.path_join("data.tau")
	mapData.tauFilePath = tauFilePath
	fileSaver.save_tau_data(tauFilePath, mapData)
	mapData.newEditorMapInit = true

func load_song(filePath:String, mapData:MapDataContainer, offsetSong:AudioStreamPlayer, mainSong:AudioStreamPlayer):
	var stream:AudioStream
	if filePath.ends_with(".mp3"):
		stream = AudioStreamMP3.load_from_file(filePath)
	elif filePath.ends_with(".ogg"):
		stream = AudioStreamOggVorbis.load_from_file(filePath)
	if stream is AudioStreamMP3 or stream is AudioStreamOggVorbis:
		offsetSong.stream = stream.duplicate()
		mainSong.stream = stream.duplicate()
		mapData.songLength = stream.get_length()
		CurrentMap.songLengthInSeconds = stream.get_length()
	else:
		push_error("Failed to load audio: " + filePath + ". File must be .mp3 or .ogg.")
