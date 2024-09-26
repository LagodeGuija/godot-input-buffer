extends Node

# in millisecs, so 50 ms = 3 frames
var buffer_window: int = 50
# deadzone default is 0.2
var joy_deadzone: float = 0.2

var keyboard_timestamps: Dictionary
var joypad_timestamps: Dictionary
var mouse_timestamps: Dictionary


# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	keyboard_timestamps = {}
	joypad_timestamps = {}
	mouse_timestamps = {}


# Called whenever the player makes an input.
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if !event.pressed or event.is_echo():
			return
		var scancode: int = event.keycode
		keyboard_timestamps[scancode] = Time.get_ticks_msec()
	elif event is InputEventJoypadButton:
		if !event.pressed or event.is_echo():
			return
		var button_index: int = event.button_index
		joypad_timestamps[button_index] = Time.get_ticks_msec()
	elif event is InputEventJoypadMotion:
		if abs(event.axis_value) < joy_deadzone:
			return
		var axis_code: String = str(event.axis) + "_" + str(sign(event.axis_value))
		joypad_timestamps[axis_code] = Time.get_ticks_msec()
	elif event is InputEventMouseButton:
		if !event.pressed:
			return
		var button_index: int = event.button_index
		mouse_timestamps[button_index] = Time.get_ticks_msec()


# Returns whether any of the keyboard keys or joypad buttons in the given action were pressed within the buffer window.
func is_action_press_buffered(action: String) -> bool:
	# Get the inputs associated with the action. If any one of them was pressed in the last BUFFER_WINDOW milliseconds,
	# the action is buffered.
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			var scancode: int = event.scancode
			if keyboard_timestamps.has(scancode):
				if Time.get_ticks_msec() - keyboard_timestamps[scancode] <= buffer_window:
					_clear_buffered_action(action)
					return true
		elif event is InputEventJoypadButton:
			var button_index: int = event.button_index
			if joypad_timestamps.has(button_index):
				if Time.get_ticks_msec() - joypad_timestamps[button_index] <= buffer_window:
					_clear_buffered_action(action)
					return true
		elif event is InputEventJoypadMotion:
			if abs(event.axis_value) < joy_deadzone:
				return false
			var axis_code: String = str(event.axis) + "_" + str(sign(event.axis_value))
			if joypad_timestamps.has(axis_code):
				if Time.get_ticks_msec() - joypad_timestamps[axis_code] <= buffer_window:
					_clear_buffered_action(action)
					return true
		elif event is InputEventMouseButton:
			var button_index: int = event.button_index
			if mouse_timestamps.has(button_index):
				if Time.get_ticks_msec() - mouse_timestamps[button_index] <= buffer_window:
					_clear_buffered_action(action)
					return true
	
	return false

func is_action_hold_buffered(action: String) -> bool:
	return is_action_press_buffered(action) or Input.is_action_pressed(action)

# Records unreasonable timestamps for all the inputs in an action. Called when IsActionPressBuffered returns true, as
# otherwise it would continue returning true every frame for the rest of the buffer window.
func _clear_buffered_action(action: String) -> void:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			var scancode: int = event.keycode
			if keyboard_timestamps.has(scancode):
				keyboard_timestamps[scancode] = 0
		elif event is InputEventJoypadButton:
			var button_index: int = event.button_index
			if joypad_timestamps.has(button_index):
				joypad_timestamps[button_index] = 0
		elif event is InputEventJoypadMotion:
			var axis_code: String = str(event.axis) + "_" + str(sign(event.axis_value))
			if joypad_timestamps.has(axis_code):
				joypad_timestamps[axis_code] = 0
		elif event is InputEventMouseButton:
			var button_index: int = event.button_index
			if mouse_timestamps.has(button_index):
				mouse_timestamps[button_index] = 0
