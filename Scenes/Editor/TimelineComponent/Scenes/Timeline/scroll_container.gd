extends ScrollContainer

signal SCROLL_CHANGED

@onready var leadInTimer = Timer.new()

@export var rootNode:Timeline
var lastScrollX:float = 0
var playHeadOffset:float = 500.0

func _ready() -> void:
	self.add_child(leadInTimer)
	leadInTimer.one_shot = true
	leadInTimer.timeout.connect(on_lead_in_timer_timeout)

func _process(_delta: float) -> void:
	self.custom_minimum_size = rootNode.get_rect().size
	get_if_scroll_changed()
	scroll_while_playing()

func get_if_scroll_changed():
	if lastScrollX != scroll_horizontal:
		lastScrollX = scroll_horizontal
		SCROLL_CHANGED.emit()

func scroll_while_playing():
	if CurrentMap.mainSongIsPlaying and CurrentMap.mapStarted:
		self.scroll_horizontal = int(CurrentMap.mainSongPosition * rootNode.pixelsPerSecond)
	elif !CurrentMap.mainSongIsPlaying and CurrentMap.mapStarted:
		self.scroll_horizontal = int(CurrentMap.mainSongPosition * rootNode.pixelsPerSecond)

func on_lead_in_timer_timeout():
	CurrentMap.manualSongPosition = 0.0
