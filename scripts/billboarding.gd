extends Node3D

@export var enabled = true


func _process(_delta):	
	if not enabled:
		return

	var current_camera = get_viewport().get_camera_3d()
	look_at(current_camera.global_position)
	var angle = rad_to_deg(angle_difference(get_parent().global_rotation.y, global_rotation.y))

	if -45.0 < angle and angle <= 45:
		pass
	elif 45.0 < angle and angle <= 135.0:
		rotation_degrees.y -= 90.0
	elif -135.0 < angle and angle <= -45.0:
		rotation_degrees.y += 90.0
	else:
		rotation_degrees.y += 180.0
