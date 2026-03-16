extends RigidBody3D

@export_flags_2d_physics var kickable_layer

@onready var player = get_node('/root/main/player')
@onready var take_damage_anim = get_node('take_damage')
@onready var player_detector = get_node('player_detector')
@onready var bullet_emitter = get_node('bullet_emitter')
@onready var navigation_grid = get_node('/root/main/navigation_grid')
@onready var pathfinding = get_node('pathfinding')
@onready var animation_override = get_node('animation_override')
@onready var main = get_node('/root/main')
@onready var shape = get_node('shape')

@export var patrol_zone:Area3D
@export var ignore_player = false

@export var health = 10

var state = 'idle'

var move_direction = Vector3.ZERO
var look_direction = Vector3.ZERO
var prev_position = Vector3.ZERO

var go_to_patrol_state_timer = 0.0
var control = 1.0
var dead = false
var player_awareness = 0.0
var reevalute_path_timer = 0.0
var hit_nodes = []


func _ready() -> void:
	add_to_group('kickable')
	add_to_group('bullet_immune')

func _process(delta: float) -> void:
	if not dead:
		linear_damp = 0.0
		
	match state:
		'idle':
			evaluate_idle_state(delta)
		'patrol':
			evaluate_patrol_state(delta)
		'falling':
			evaluate_falling_state(delta)
		'aggressive':
			evaluate_aggressive_state(delta)
	
func _physics_process(_delta: float) -> void:
	if not custom_integrator:
		var collisions = main.get_nodes_in_shape(shape, 'kickable', kickable_layer, global_position - prev_position)
		collisions.erase(self)
		for node in collisions:
			if node not in hit_nodes:
				node.kick(prev_position, linear_velocity.length() * 50.0)
				linear_velocity *= 0.75
				hit_nodes.append(node)

		prev_position = global_position


func _integrate_forces(_state: PhysicsDirectBodyState3D) -> void:
	if dead:
		return
	if not custom_integrator:
		return

	match state:
		'idle', 'patrol':
			linear_velocity = move_direction
			if look_direction != Vector3.ZERO:
				look_at(global_position + look_direction)
		'aggressive':
			linear_velocity = move_direction
			look_at(player.global_position)

func kick(source_position, force):
	if dead:
		return

	var kick_direction = (global_position - source_position) * Vector3(1.0, 0.0, 1.0).normalized()

	go_to_falling_state()

	hit_nodes = []
	control = -2.5

	apply_impulse(kick_direction * force)
	take_damage()

func _on_body_entered(_body: Node) -> void:
	if custom_integrator == false and linear_velocity.length() > 1.0:
		take_damage()

func take_damage():
	take_damage_anim.play('take_damage')

	health -= 1

	if health <= 0 and not dead:
		dead = true
		if control < 0.2:
			control = 0.2
		animation_override.play('death')


func evaluate_idle_state(delta):
	if dead:
		return

	if try_go_to_aggressive_state(delta):
		return

	move_direction = Vector3.ZERO

	go_to_patrol_state_timer += delta
	if go_to_patrol_state_timer >= 1.0:
		if patrol_zone != null:
			go_to_patrol_state()

func evaluate_patrol_state(delta):
	if try_go_to_aggressive_state(delta):
		return

	move_direction = pathfinding.move_direction
	if move_direction != Vector3.ZERO:
		look_direction = move_direction

func evaluate_falling_state(delta):
	if control < 1.0:
		var regain_control_mult = 1.0
		if linear_velocity.length() < 2.0 or control > 0.2:
			regain_control_mult *= 2.0
			linear_damp = 2.0
		elif linear_velocity.length() < 0.04 or control > 0.5:
			regain_control_mult *= 5.0
			linear_damp = 3.0
		control += regain_control_mult * delta
	else:
		go_to_idle_state()

func evaluate_aggressive_state(delta):
	if dead:
		return
		
	reevalute_path_timer += delta;

	if (pathfinding.target_node == null) or (reevalute_path_timer >= 1.0):
		reevalute_path_timer = 0.0
		var possible_player_nodes = player.get_valid_enemy_movement_targets()

		if possible_player_nodes != []:
			pathfinding.set_target_node(possible_player_nodes.pick_random())
	
	move_direction = pathfinding.move_direction


func try_go_to_aggressive_state(delta):
	if dead:
		return false

	var prev_player_awareness = player_awareness

	if not (ignore_player or dead):
		if player_detector.detecting_player:
			player_awareness += delta
			if player_awareness > 2.0:
				player_awareness = 2.0
	

	if prev_player_awareness < 1.0 and player_awareness >= 1.0:
		go_to_aggressive_state()
		return true
	
	return false

func go_to_patrol_state():
	state = 'patrol'

	bullet_emitter.emitting = false
	custom_integrator = true

	var possible_grid_nodes = []
	for child in navigation_grid.get_children():
		if patrol_zone.is_pos_inside(child.global_position):
			possible_grid_nodes.append(child)

	var target_grid_node = possible_grid_nodes.pick_random()
	pathfinding.set_target_node(target_grid_node)

func go_to_idle_state():
	if dead:
		return
		
	bullet_emitter.emitting = false
	custom_integrator = true
	go_to_patrol_state_timer = 0.0
	state = 'idle'

	pathfinding.clear_target_node()

func go_to_falling_state():
	if state == 'falling':
		return

	state = 'falling'

	bullet_emitter.emitting = false
	custom_integrator = false
	prev_position = global_position

	pathfinding.clear_target_node()

func go_to_aggressive_state():
	state = 'aggressive'

	bullet_emitter.emitting = true
	custom_integrator = true

	pathfinding.clear_target_node()

func pathfinding_finished():
	pathfinding.clear_target_node()

	match state:
		'patrol':
			go_to_idle_state()

	
func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == 'death':
		queue_free()
