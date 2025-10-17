extends Node2D

var targetScale:Vector2
var startScaleL:Vector2
var startScaleR:Vector2
var animating:bool

func _ready() -> void:
	targetScale = Vector2(1.2, 1.2)
	startScaleL = $HitNodeLeft.scale
	startScaleR = $HitNodeRight.scale

	if !CurrentMap.inEditor:
		# --- GAMEPLAY ---
		# --- KEY 1 ---
		InputManager.PLAYER_KEY_1_PRESSED.connect(hit_node_hit)
		InputManager.PLAYER_KEY_1_RELEASED.connect(hit_node_release)
		# --- KEY 2 ---
		InputManager.PLAYER_KEY_2_PRESSED.connect(hit_node_hit)
		InputManager.PLAYER_KEY_2_RELEASED.connect(hit_node_release)
	else:
		# --- EDITOR ---
		# --- KEY 1 ---
		if InputManager.PLAYER_KEY_1_PRESSED.is_connected(hit_node_hit):
			InputManager.PLAYER_KEY_1_PRESSED.disconnect(hit_node_hit)
		if InputManager.PLAYER_KEY_1_RELEASED.is_connected(hit_node_release):
			InputManager.PLAYER_KEY_1_RELEASED.disconnect(hit_node_release)
		# --- KEY 2 ---
		if InputManager.PLAYER_KEY_2_PRESSED.is_connected(hit_node_hit):
			InputManager.PLAYER_KEY_2_PRESSED.disconnect(hit_node_hit)
		if InputManager.PLAYER_KEY_2_RELEASED.is_connected(hit_node_release):
			InputManager.PLAYER_KEY_2_RELEASED.disconnect(hit_node_release)

func hit_node_hit(_mapTimeOnPress:float, key:int):
	var startTime:float = CurrentMap.globalMapTimeInSeconds
	pass
	if key == -1:
		pass
	elif key == 1:
		pass

func hit_node_release(_mapTimeOnPress:float, key:int):
	var startTime:float = CurrentMap.globalMapTimeInSeconds
	if key == -1:
		pass
	elif key == 1:
		pass
