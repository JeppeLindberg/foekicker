@tool
extends Node3D

@export var main: Node3D
@export var los_detector: CollisionShape3D

@export_flags_2d_physics var navgrid_mask


func is_los_connected(from, to):
	# return true

	from = Vector3(from.x, 0, from.z)
	to = Vector3(to.x, 0, to.z)
	los_detector.global_position = from
	if main.get_nodes_in_shape(los_detector, '', navgrid_mask, to - from) != []:
		return false
	los_detector.global_position = to
	if main.get_nodes_in_shape(los_detector, '', navgrid_mask, from - to) != []:
		return false

	return true
		

