extends RigidBody3D

@onready var player = get_node('/root/main/player')
@onready var take_damage_anim = get_node('take_damage')



func _ready() -> void:
	add_to_group('kickable')
	add_to_group('bullet_immune')

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
