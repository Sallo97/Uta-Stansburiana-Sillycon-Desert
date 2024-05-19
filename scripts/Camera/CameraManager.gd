extends Node3D

@export var trackball_camera: Camera3D
@export var free_camera: Camera3D

func _process(_delta):
	if Input.is_action_just_pressed("camera_change"):
		if trackball_camera.current:
			free_camera.make_current()
		else:
			trackball_camera.make_current()
