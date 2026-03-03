extends RigidBody3D

@onready var player = get_node('/root/main/player')
@onready var take_damage_anim = get_node('take_damage')
@onready var player_detector = get_node('player_detector')
@onready var bullet_emitter = get_node('bullet_emitter')
@onready var navigation_grid = get_node('/root/main/navigation_grid')
@onready var pathfinding = get_node('pathfinding')

@export var patrol_zone:Area3D
@export var ignore_player = false


var hesitation_time = 0.0
var state = 'idle'


func _ready() -> void:
	add_to_group('kickable')
	add_to_group('bullet_immune')

func _process(delta: float) -> void:
	evaluate_state(delta)

	print(patrol_zone.is_pos_inside(global_position))

	if ignore_player:
		bullet_emitter.emitting = false
		return

	bullet_emitter.emitting = player_detector.detecting_player

func _physics_process(_delta: float) -> void:
	look_at(player.global_position)

func kick(kick_source_node):
	var kick_direction = (global_position - kick_source_node.global_position) * Vector3(1.0, 0.0, 1.0).normalized()
	
	linear_velocity = Vector3.ZERO
	apply_impulse(kick_direction * kick_source_node.kick_force)


func _on_body_entered(_body: Node) -> void:
	if Vector3.ZERO.distance_to(linear_velocity) > 1.0:
		take_damage()

func take_damage():
	take_damage_anim.play('take_damage')

func evaluate_state(delta):	
	var evaluate_new_state = false
	if hesitation_time < 1.0:
		if state == 'idle':
			hesitation_time += delta
		if hesitation_time >= 1.0:
			evaluate_new_state = true

	if not evaluate_new_state:
		return

	match state:
		'idle':
			if patrol_zone != null:
				start_patrol_state()

func start_patrol_state():
	hesitation_time = 0.0
	state = 'patrol'

	var possible_grid_nodes = []
	for child in navigation_grid.get_children():
		if patrol_zone.is_pos_inside(child.global_position):
			possible_grid_nodes.append(child)

	var target_grid_node = possible_grid_nodes.pick_random()
	pathfinding.set_target_node(target_grid_node)
