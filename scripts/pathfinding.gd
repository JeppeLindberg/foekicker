@tool
extends Node3D

@export var navigation_grid: Node3D
@export var pathfinding_mgt: Node3D

@export var neighbour_prefab: PackedScene

@export_tool_button("Test", "Callable") var test_callable = test

var target_node = null
var path = []
var recreate_children = false
var fast = false

var move_direction = Vector3.ZERO

func _ready() -> void:
	if pathfinding_mgt == null:
		pathfinding_mgt = get_node('/root/main/pathfinding_mgt')
	if navigation_grid == null:
		navigation_grid = get_node('/root/main/navigation_grid')

func set_target_node(new_target_node):
	path = []
	target_node = new_target_node
	move_direction = Vector3.ZERO

func clear_target_node():
	path = []
	target_node = null
	move_direction = Vector3.ZERO

func _process(_delta):
	if Engine.is_editor_hint():
		if recreate_children:
			for child in get_children():
				child.queue_free()
			for i in range(len(path) - 1):
				var neighbour_indicator = neighbour_prefab.instantiate()
				add_child(neighbour_indicator)
				neighbour_indicator.owner = get_tree().edited_scene_root
				neighbour_indicator.global_position = path[i].global_position
				neighbour_indicator.target_position = path[i+1].global_position - path[i].global_position

			recreate_children = false
		return

	if target_node == null:
		return

	if path == []:
		fast = true
		await create_path(global_position, target_node.global_position)

	if path != []:
		if (global_position*Vector3(1.0,0.0,1.0)).distance_to(path[0].global_position*Vector3(1.0,0.0,1.0)) < 0.5:
			path.pop_front()
		if path == []:
			get_parent().pathfinding_finished()
	
	if path != []:
		move_direction = ((path[0].global_position - global_position) * Vector3(1.0,0.0,1.0)).normalized()
	else:
		move_direction = Vector3.ZERO

func test():
	for child in get_children():
		child.queue_free()
		
	var from = navigation_grid.get_children().pick_random()
	var to = navigation_grid.get_children().pick_random()

	fast = false
	await create_path(from.global_position, to.global_position)


var navgrid_node_from = null
var navgrid_node_to = null
var explored_nodes = []
var frontier = []

func create_path(from, to):
	path = []

	navgrid_node_from = navigation_grid.get_closest_nav_node(from)
	navgrid_node_to = navigation_grid.get_closest_nav_node(to)

	explored_nodes = []
	frontier = [{
		'node': navgrid_node_from,
		'index_from': null
	}]

	path = explore_frontier()

	if path == null or path == []:
		print('unsolvable path')
		recreate_children = true
		path = [navgrid_node_from, navgrid_node_to]
		return
	
	recreate_children = true
	if not fast:
		await get_tree().create_timer(0.2).timeout

	var cull_attempt_indexes = range(1, len(path) - 1)
	cull_attempt_indexes.shuffle()

	for i in range(len(cull_attempt_indexes)):
		var pos_from = path[cull_attempt_indexes[i]-1].global_position
		var pos_to = path[cull_attempt_indexes[i]+1].global_position
		if pos_from.distance_to(pos_to) < 3.0 and pathfinding_mgt.is_los_connected(pos_from, pos_to):
			path.remove_at(cull_attempt_indexes[i])
			for j in range(len(cull_attempt_indexes)):
				if cull_attempt_indexes[j] > cull_attempt_indexes[i]:
					cull_attempt_indexes[j] -= 1
		
			recreate_children = true
			if not fast:
				await get_tree().create_timer(0.2).timeout

func explore_frontier():
	for i in range(len(frontier)-1,-1,-1):
		for neighbour in frontier[i]['node'].neighbours:
			var add_neighbour = true
			for pair in (frontier + explored_nodes):
				if pair['node'] == neighbour:
					add_neighbour = false
			if add_neighbour:
				frontier.append({
					'node': neighbour,
					'index_from': len(explored_nodes)})
	
		explored_nodes.append({
			'node': frontier[i]['node'],
			'index_from': frontier[i]['index_from']
			})

		if explored_nodes[len(explored_nodes) - 1]['node'] == navgrid_node_to:
			return retread_path()

		frontier.remove_at(i)
	
	if frontier != []:
		return explore_frontier()
	else:
		return []

func retread_path():
	var result = []
	
	var index = len(explored_nodes) - 1
	while true:
		result.append(explored_nodes[index]['node'])
		index = explored_nodes[index]['index_from']

		if result[len(result) - 1] == navgrid_node_from:
			break

	result.reverse()
	return result
		
