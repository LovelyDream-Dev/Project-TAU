extends Control
class_name MainMenu

@export_category("Parallax")
@export var parallax:ParallaxGUI
var _enableParallax:bool = true
@export var enableParallax:bool = true:
	set(value):
		if _enableParallax != value:
			_enableParallax = value
			toggle_parallax(value)
	get:
		return _enableParallax
@export_group("Movement")
@export var maximumMovement:Vector2 = Vector2(8.0, 8.0)
@export var movementDecrease:float = 0.5

@export_category("Blur")
@export var enableBlur:bool = true
@export_range(0.1, 20.0, 0.1) var blurStrength:float = 4.0
@export var blurShaderMaterial:ShaderMaterial

@export_category("Buttons")
@export_group("Settings")
@export var settingsButton:StyleButton
@export var settingsIconLarge:TextureRect
@export_group("Editor")
@export var editorButton:StyleButton

var loadedMapPath:String

func _ready() -> void:
	GlobalFunctions.toggle_borderless()

func _process(_delta: float) -> void:
	manage_song_queue()
	if parallax and enableParallax:
		parallax.maximumMovement = maximumMovement
		parallax.movementDecrease = movementDecrease
	toggle_blur()
	animate_settings()

func toggle_parallax(value):
	if parallax:
		if value == false:
			parallax.maximumMovement = Vector2.ZERO
		else:
			parallax.maximumMovement = Vector2(8.0, 8.0)

func toggle_blur():
	if enableBlur:
		if parallax and parallax.controls.size() > 0:
			for control:Control in parallax.controls:
				control.material = blurShaderMaterial
		if blurShaderMaterial:
			blurShaderMaterial.set_shader_parameter("blur_strength", blurStrength)

func animate_settings():
	if settingsIconLarge:
		settingsIconLarge.rotation = (TAU*0.25)/(60/CurrentMap.bpm) * CurrentMap.globalMapTimeInSeconds

func manage_song_queue():
	var idx:int = 0
	if idx < MaestroSingleton.songQueue.size():
		if loadedMapPath != MaestroSingleton.songQueue[idx]:
			loadedMapPath = MaestroSingleton.songQueue[idx]
			MaestroSingleton.play_songs()
			await MaestroSingleton.offsetSong.finished
			idx += 1
