extends ScrollContainer

signal SCROLL_CHANGED

@export var rootNode:Timeline
var lastScrollX:float = 0
var playHeadOffset:float = 500.0

func _process(_delta: float) -> void:
	self.custom_minimum_size = rootNode.get_rect().size
	get_if_scroll_changed()
	handle_scroll()

func get_if_scroll_changed():
	if lastScrollX != scroll_horizontal:
		lastScrollX = scroll_horizontal
		SCROLL_CHANGED.emit()

func handle_scroll():
	if CurrentMap.mapStarted:
		# Positive lead in
		if CurrentMap.leadInTime > 0:
			if CurrentMap.editorOffsetSongIsPlaying:
				self.scroll_horizontal = int(CurrentMap.editorOffsetSongPosition * rootNode.pixelsPerSecond)
				return 
		else:
			await get_tree().create_timer(CurrentMap.leadInTime).timeout

		if CurrentMap.mainSongIsPlaying:
			print(self.scroll_horizontal)
			self.scroll_horizontal = int((CurrentMap.mainSongPosition + CurrentMap.leadInTime) * rootNode.pixelsPerSecond)
