extends RigidBody3D

@onready var take_damage_anim = get_node('take_damage')

var control = 1.0


func _ready() -> void:
	add_to_group('kickable')
	add_to_group('bullet_immune')


func _process(delta: float) -> void:	
	if control < 1.0:
		var regain_control_mult = 1.0
		if linear_velocity.length() < 0.4:
			regain_control_mult *= 5.0
			linear_damp = 2.0
		elif linear_velocity.length() < 0.04:
			regain_control_mult *= 50.0
			linear_damp = 3.0
		control += regain_control_mult * delta

func kick(kick_source_node):
	var kick_direction = (global_position - kick_source_node.global_position) * Vector3(1.0, 0.0, 1.0).normalized()
	
	linear_velocity = Vector3.ZERO
	control = -2.0
	
	apply_impulse(kick_direction * kick_source_node.kick_force)
	take_damage()


func _on_body_entered(_body: Node) -> void:
	if Vector3.ZERO.distance_to(linear_velocity) > 1.0:
		take_damage()

func take_damage():
	take_damage_anim.play('take_damage')
