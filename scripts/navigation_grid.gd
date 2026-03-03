@tool
extends Node3D

@export var main: Node3D
@export var pathfinding_mgt: Node3D

@export var force_display_play_mode = false

@export var grid_node: PackedScene
@export var neighbour_prefab: PackedScene
@export var distance_between_nodes = 1.0
@export var max_nodes = 100
@export_flags_2d_physics var navgrid_mask


@export_tool_button("Recreate", "Callable") var recreate_callable = recreate
@export_tool_button("Clear", "Callable") var clear_callable = clear


var frontier = []
var explored_vectors = []


func _process(_delta):
	if not Engine.is_editor_hint() or force_display_play_mode:
		visible = false
	else:
		visible = true

func clear():
	for child in get_children():
		child.queue_free()

func recreate():
	force_display_play_mode = false
	
	clear()

	frontier = []
	explored_vectors = []

	frontier.append(Vector3.ZERO)

	await explore_frontier()

	print('discover neighbours')

	var nodes_to_delete = []

	for from in get_children():
		for to in get_children():
			if from.global_position.distance_to(to.global_position) < distance_between_nodes * 1.2:
				if pathfinding_mgt.is_los_connected(from.global_position, to.global_position):
					var neighbour_indicator = neighbour_prefab.instantiate()
					from.add_child(neighbour_indicator)
					neighbour_indicator.owner = get_tree().edited_scene_root
					neighbour_indicator.global_position = from.global_position
					neighbour_indicator.target_position = to.global_position - from.global_position
					from.neighbours.append(to)

		if len(from.neighbours) == 0:
			nodes_to_delete.append(from)
		else:
			from.neighbours.make_read_only()

		await get_tree().create_timer(0.02).timeout
	
	for i in range(len(nodes_to_delete) -1, -1, -1):
		nodes_to_delete[i].queue_free()

	print('done')


func explore_frontier():
	for i in range(len(frontier)-1,-1,-1):
		var space_state = get_world_3d().direct_space_state
		var raycast = PhysicsRayQueryParameters3D.create(
			global_position + Vector3.UP * 30.0 + frontier[i], 
			global_position + Vector3.DOWN * 30.0 + frontier[i],
			navgrid_mask)
		var result = space_state.intersect_ray(raycast)
		if result:
			var node = result.collider
			if node != null and node.is_in_group('navgrid'):
				var point = result.position
				var new_node = grid_node.instantiate()
				add_child(new_node)
				new_node.owner = get_tree().edited_scene_root
				new_node.global_position = point

				await get_tree().create_timer(0.02).timeout

				if get_child_count() > max_nodes:
					print('max nodes reached')
					return
				
				var n_gon = 6
				for j in range(n_gon):
					var new_vec = frontier[i] + Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(j * (360.0 / n_gon))) * distance_between_nodes
					var add_new_vec = true
					for existing_vec in frontier + explored_vectors:
						if existing_vec.distance_to(new_vec) < 0.2:
							add_new_vec = false
							break
					if add_new_vec:
						frontier.append(new_vec)
		
		explored_vectors.append(frontier[i])

		frontier.remove_at(i)
	
	if frontier != []:
		await explore_frontier()
	

func get_closest_nav_node(pos):
	var distance = 9999.9
	var result = null
	for child in get_children():
		var dist = pos.distance_to(child.global_position)
		if dist < distance:
			distance = dist
			result = child
			
	return result

