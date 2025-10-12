@tool
extends Node2D
class_name Visual_Lazer

@onready var dashes:Line2D = $Dashes
@onready var beam:Line2D = $Beam

# --- Exported Colors ---
@export_category("Colors")
@export var dashColor:Color
@export var beamColor:Color

# --- Exported Values ---
@export_category("Values")
@export var dashFrequency:float = 0.5
@export var dashSpeed:float = 10.0
@export var dashWidth:float = 5.0
@export_range(-1.0,1.0,0.001) var dashDirection:float = 1.0
@export_range(-1.0,1.0,0.001) var dashOpacity:float = 1.0
@export var beamLength:float = 500
@export var beamWidth:float = 5.0

func _ready() -> void:
	set_process(true)

func _process(_delta: float) -> void:
	var dashesMaterial:ShaderMaterial = dashes.material
	dashesMaterial.set_shader_parameter("frequency", dashFrequency)
	dashesMaterial.set_shader_parameter("speed", dashSpeed)
	dashesMaterial.set_shader_parameter("color1", dashColor)
	dashesMaterial.set_shader_parameter("direction", dashDirection)
	dashesMaterial.set_shader_parameter("opacity", dashOpacity)
	dashes.width = dashWidth
	dashes.queue_redraw()
	beam.default_color = beamColor

var beamtw:Tween
func activate_beam(activate:bool):
	if beamtw and beamtw.is_running(): beamtw.kill()
	beamtw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT).parallel()
	if activate:
		beam.modulate.a = 1
		beamtw.tween_property(beam, "width", beamWidth, 0.025)
	else:
		beamtw.tween_property(beam, "width", 0, 0.2)
		beamtw.tween_property(beam, "modulate:a", 0, 0.15)
