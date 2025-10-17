extends Node

signal MOUSE_BUTTON_LEFT_PRESSED
signal MOUSE_BUTTON_LEFT_RELEASED
signal MOUSE_BUTTON_RIGHT_PRESSED
signal MOUSE_BUTTON_RIGHT_RELEASED
signal KEY_SPACE_PRESSED
signal KEY_SPACE_RELEASED
signal KEY_ESCAPE_PRESSED
signal KEY_ESCAPE_RELEASED

signal PLAYER_KEY_1_PRESSED
signal PLAYER_KEY_1_RELEASED
signal PLAYER_KEY_2_PRESSED
signal PLAYER_KEY_2_RELEASED

func _input(_event: InputEvent) -> void:
	var mapTime:float
	if CurrentMap.globalMapTimeInSeconds:
		mapTime = CurrentMap.globalMapTimeInSeconds
	# --- GAME KEYS ---
	# --- KEY 1 ---
	if Input.is_action_just_pressed("KEY1"):
		PLAYER_KEY_1_PRESSED.emit(mapTime, -1)
	if Input.is_action_just_released("KEY1"):
		PLAYER_KEY_1_RELEASED.emit(mapTime, -1)
	# --- KEY 2 ---
	if Input.is_action_just_pressed("KEY2"):
		PLAYER_KEY_2_PRESSED.emit(mapTime, 1)
	if Input.is_action_just_released("KEY2"):
		PLAYER_KEY_2_RELEASED.emit(mapTime, 1)

	# --- MOUSE BUTTONS ---
	# --- LEFT MOUSE BUTTON ---
	if Input.is_action_just_pressed("LMB"):
		MOUSE_BUTTON_LEFT_PRESSED.emit(mapTime)
	if Input.is_action_just_released("LMB"):
		MOUSE_BUTTON_LEFT_RELEASED.emit(mapTime)
	# --- RIGHT MOUSE BUTTON
	if Input.is_action_just_pressed("RMB"):
		MOUSE_BUTTON_RIGHT_PRESSED.emit(mapTime)
	if Input.is_action_just_released("RMB"):
		MOUSE_BUTTON_RIGHT_RELEASED.emit(mapTime)

	# --- KEYBOARD KEYS ---
	# --- SPACE ---
	if Input.is_action_just_pressed("SPACE"):
		KEY_SPACE_PRESSED.emit(mapTime)
	if Input.is_action_just_released("SPACE"):
		KEY_SPACE_RELEASED.emit(mapTime)
	# --- ESCAPE ---
	if Input.is_action_just_pressed("ESCAPE"):
		KEY_ESCAPE_PRESSED.emit(mapTime)
	if Input.is_action_just_released("ESCAPE"):
		KEY_ESCAPE_RELEASED.emit(mapTime)
