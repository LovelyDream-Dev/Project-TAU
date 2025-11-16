extends MultiMeshInstance2D

@export var spectrumCurve:Curve2D
@export var resolution:int = 128
@export var maxBarHeight:float = 100.0
@export var barColor:Color = Color.WHITE

func _ready() -> void:
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_2D
	mm.use_custom_data = true
	mm.instance_count = resolution
	multimesh = mm

	var barMesh:QuadMesh = QuadMesh.new()
	barMesh.size = Vector2(4 , 1)
	multimesh.mesh = barMesh

	for i in range(resolution):
		multimesh.set_instance_custom_data(i, barColor)

func _process(_delta: float) -> void:
	var fftAmps: Array = getFFTAmplitudes()
	update_spectrum(fftAmps)

func getFFTAmplitudes(size: int = 128) -> Array:
	var analyzer = AudioServer.get_bus_effect_instance(1, 0) as AudioEffectSpectrumAnalyzerInstance
	if analyzer == null:
		push_error("Spectrum analyzer instance is null!")
		return []

	var amps: Array = []

	# We'll split the full audible range (20Hz–20kHz) into `size` bands
	var minFreq = 20.0
	var maxFreq = 20000.0
	var logMin = log(minFreq)
	var logMax = log(maxFreq)

	for i in range(size):
		# Compute logarithmically spaced frequency bands
		var t0 = float(i) / size
		var t1 = float(i + 1) / size
		var f0 = exp(logMin + t0 * (logMax - logMin))
		var f1 = exp(logMin + t1 * (logMax - logMin))
		var mag = analyzer.get_magnitude_for_frequency_range(f0, f1)
		# Average left + right channels
		amps.append((mag.x + mag.y) * 0.5)

	return amps

func update_spectrum(amplitudes: Array):
	var total_length = spectrumCurve.get_baked_length()
	for i in range(resolution):
		# compute an offset along the curve (in pixels)
		var t = float(i) / float(resolution - 1)
		var offset = t * total_length

		# sample the baked curve at that offset
		var pos = spectrumCurve.sample_baked(offset, false)  # false = linear interpolation

		var height = amplitudes[i] * maxBarHeight

		var xform = Transform2D()
		xform.origin = pos
		xform.scaled(Vector2(1, height)) 
		multimesh.set_instance_transform_2d(i, xform)
