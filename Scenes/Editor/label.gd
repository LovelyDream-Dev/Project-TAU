extends Label

func _process(_delta: float) -> void:
	text = str(snappedf(CurrentMap.globalMapTimeInSeconds, 0.01))
