extends Area3D



func is_pos_inside(pos):
	var query = PhysicsPointQueryParameters3D.new()
	query.position = pos
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var nodes = get_world_3d().direct_space_state.intersect_point(query)
	for node in nodes:
		if node['collider'] == self:			
			return true
	
	return false
