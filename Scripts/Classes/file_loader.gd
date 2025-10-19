extends Node
class_name FileLoader

var maestro:Maestro = MaestroSingleton

var fileSaver:FileSaver = FileSaver.new()

var originalAudioFileName:String
var mapFolderPath:String
var AudioFileExtension:String

## Takes the folder of the specific map and loads the map
func load_map(folderPath:String):
	CurrentMap.unload_map()
	var dir = DirAccess.open(folderPath)
	if dir == null:
		push_error("Could not open folder: "+folderPath)
		return

	dir.list_dir_begin()
	var fileName = dir.get_next()
	while fileName != "": # if there are no more files, filename will be ""
		if not dir.current_is_dir():
			if fileName.ends_with(".tau"):
				CurrentMap.tauFilePath = folderPath.path_join(fileName)
				load_tau_file(CurrentMap.tauFilePath, folderPath)
		fileName = dir.get_next()
	dir.list_dir_end()
	

func load_tau_file(filePath:String, folderPath:String):
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
				load_song(audioFilePath)
			elif line.begins_with("LeadInTimeMS:"):
				var parts = line.split(":", false, 1) # split into [ "LeadInTimeMS", value]
				CurrentMap.LeadInTimeMS = float(parts[1])

		if inMetadata:
			if line.begins_with("Title:"):
				var parts = line.split(":", false, 1)
				CurrentMap.title = parts[1].strip_edges()
			elif line.begins_with("Artist:"):
				var parts = line.split(":", false, 1)
				CurrentMap.artist = parts[1].strip_edges()
			elif line.begins_with("Creator:"):
				var parts = line.split(":", false, 1)
				CurrentMap.creator = parts[1].strip_edges()
			elif line.begins_with("Version:"):
				var parts = line.split(":", false, 1)
				CurrentMap.version = parts[1].strip_edges()

		if inDifficulty:
			if line.begins_with("HpDrainRate:"):
				var parts = line.split(":", false, 1)
				CurrentMap.hpDrainRate = float(parts[1])
			if line.begins_with("HitWindow:"):
				var parts = line.split(":", false, 1)
				CurrentMap.hitWindowInSeconds = float(parts[1])/1000

		# Format for timing points in the tau file: "time: value, bpm: value"
		# Format for timing points as a dictionary: {"time": value,"bpm": value} 
		if inTimingPoints:
			var parts = line.split(",")
			if parts.size() == 2:
				var timingPoint = {
					"time": float(parts[0].substr(5).strip_edges()),
					"bpm": float(parts[1].substr(4).strip_edges())
				}
				CurrentMap.timingPoints.append(timingPoint)

		# Format for hit objects in the tau file: "Note start, Note end, Note type"
		# Note type 0 is left and note type 1 is right
		# Format for hit objects as a dictionary: {"start" : value, "end" : value, "type": value}
		if inHitObjects:
			var parts = line.split(",")
			if parts.size() == 3:
				var hitObject = {
					"hitTime": float(parts[0].strip_edges()),
					"releaseTime": float(parts[1].strip_edges()),
					"side": int(parts[2].strip_edges())
				}
				CurrentMap.hitObjects.append(hitObject)

func init_new_map(songFilePath:String):
	originalAudioFileName = songFilePath.get_file().get_basename()
	AudioFileExtension = songFilePath.get_file().get_extension()

	CurrentMap.audioFileExtension = AudioFileExtension.to_lower()

	load_song(songFilePath)
	
	var mapsPath:String = "user://maps"
	# The name of the map folder is the name of the song
	mapFolderPath = mapsPath.path_join(originalAudioFileName+AudioFileExtension.to_lower())

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
	CurrentMap.tauFilePath = tauFilePath
	fileSaver.save_tau_data(tauFilePath)
	CurrentMap.editorMapInit = true

func load_song(filePath:String):
	var stream:AudioStream
	if filePath.ends_with(".mp3"):
		stream = AudioStreamMP3.load_from_file(filePath)
	elif filePath.ends_with(".ogg"):
		stream = AudioStreamOggVorbis.load_from_file(filePath)
	if stream is AudioStreamMP3 or stream is AudioStreamOggVorbis:
		CurrentMap.songLengthInSeconds = stream.get_length()
		maestro.offsetSong.stream = stream.duplicate()
		maestro.mainSong.stream = stream.duplicate()
	else:
		push_error("Failed to load audio: " + filePath + ". File must be .mp3 or .ogg.")
