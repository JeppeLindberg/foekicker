extends RigidBody3D

@export_flags_2d_physics var kickable_layer

@onready var take_damage_anim = get_node('take_damage')
@onready var main = get_node('/root/main')
@onready var shape = get_node('shape')

var control = 1.0
var prev_position = Vector3.ZERO
var hit_nodes = []


func _ready() -> void:
	add_to_group('kickable')
	add_to_group('bullet_immune')


func _physics_process(delta: float) -> void:
	linear_damp = 0.0
	
	if control < 10.0:
		var regain_control_mult = 1.0
		if linear_velocity.length() < 2.0 or control > 0.2:
			regain_control_mult *= 2.0
			linear_damp = 2.0
		elif linear_velocity.length() < 0.04 or control > 0.5:
			regain_control_mult *= 5.0
			linear_damp = 3.0
		control += regain_control_mult * delta
		
	if prev_position.distance_to(global_position) > 0.01:
		var collisions = main.get_nodes_in_shape(shape, 'kickable', kickable_layer, global_position - prev_position)
		collisions.erase(self)
		for node in collisions:
			if node not in hit_nodes:
				node.kick(prev_position, linear_velocity.length() * 50.0)
				linear_velocity *= 0.75
				hit_nodes.append(node)

		prev_position = global_position

func kick(source_position, force):
	var kick_direction = (global_position - source_position) * Vector3(1.0, 0.0, 1.0).normalized()
	
	hit_nodes = []
	control = -2.0
	
	apply_impulse(kick_direction * force)
	take_damage()


func _on_body_entered(_body: Node) -> void:
	if Vector3.ZERO.distance_to(linear_velocity) > 1.0:
		take_damage()

func take_damage():
	take_damage_anim.play('take_damage')
