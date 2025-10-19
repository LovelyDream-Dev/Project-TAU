extends ScrollContainer

signal SCROLL_CHANGED

var maestro:Maestro = MaestroSingleton
var elapsedLeadInTimeSeconds:float

@export var rootNode:Timeline
var lastScrollX:float = 0
var playheadOffset:float = 500.0
var manuallyScrolling:bool:
	set(value):
		manuallyScrolling = value
		on_manual_scroll(value)

var scrollTimer:float = 0.15

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if self.get_rect().has_point(self.make_input_local(event).position):
			if event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_LEFT, MOUSE_BUTTON_WHEEL_RIGHT]:
				manuallyScrolling = true

func _process(delta: float) -> void:
	queue_redraw()
	self.custom_minimum_size = rootNode.get_rect().size

	# Handle getting if manual scroll stopped
	if manuallyScrolling:
		scrollTimer -= delta
		if scrollTimer <= 0.0:
			manuallyScrolling = false
			scrollTimer = 0.15

	if get_if_scroll_changed():
		SCROLL_CHANGED.emit()

	if !manuallyScrolling:
		handle_scroll()
	else:
		CurrentMap.globalMapTimeInSeconds = self.scroll_horizontal / rootNode.pixelsPerSecond
		maestro.pause_songs()


func get_if_scroll_changed() -> bool:
	if lastScrollX != scroll_horizontal:
		lastScrollX = scroll_horizontal
		return true
	else:
		return false

func handle_scroll():
	if CurrentMap.mapStarted:
		# Use elapsedLeadInTimeSeconds to manage lead in time with scrolling
		GameData.mtween.mtween_property(self, "elapsedLeadInTimeSeconds", 0.0, (CurrentMap.LeadInTimeMS/1000.0), 0.0, abs(CurrentMap.LeadInTimeMS/1000.0))
		if abs(elapsedLeadInTimeSeconds) < abs(CurrentMap.LeadInTimeMS/1000.0):
			self.scroll_horizontal = int(abs(elapsedLeadInTimeSeconds) * rootNode.pixelsPerSecond)
		else:
			self.scroll_horizontal = int(abs(CurrentMap.globalMapTimeInSeconds) * rootNode.pixelsPerSecond)

func on_manual_scroll(value):
	if value == false:
		if CurrentMap.mapStarted:
			maestro.play_songs()
		else:
			CurrentMap.globalMapTimeInSeconds = self.scroll_horizontal / rootNode.pixelsPerSecond
