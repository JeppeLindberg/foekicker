extends Node3D

@export_flags_2d_physics var basic_layer

func get_nodes_in_shape(collider, group = '', collision_mask = 0, motion = Vector3.ZERO):
	var shape = PhysicsShapeQueryParameters3D.new()
	shape.shape = collider.shape;
	shape.transform = collider.global_transform
	shape.collide_with_areas = true
	if collision_mask != 0:
		shape.collision_mask = collision_mask
	else:
		shape.collision_mask = basic_layer
	if motion != Vector3.ZERO:
		shape.motion = motion
	var collisions = get_world_3d().direct_space_state.intersect_shape(shape);
	if collisions == null:
		return([])
	
	var nodes = []
	for collision in collisions:
		var node = collision['collider'];
		if (group == '') or node.is_in_group(group):
			nodes.append(node)
	return nodes

