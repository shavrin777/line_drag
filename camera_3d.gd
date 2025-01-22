extends Camera3D

var sensitivity = 0.0025

func  _input(event):
	if Input.is_action_pressed("cam_rotate") and event is InputEventMouseMotion:
		global_transform = global_transform.rotated(Vector3.UP, -event.relative.x * sensitivity)
		global_transform = global_transform.rotated(basis.x, -event.relative.y * sensitivity)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
		global_position = global_position * 0.9
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
		global_position = global_position * 1.1
