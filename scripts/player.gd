extends CharacterBody3D

@export var kick_detector: CollisionShape3D

@onready var main = get_node('/root/main')
@onready var head = get_node('head')
@onready var animation = get_node('animation')
@onready var full_screen_effect_mgt = get_node('/root/main/full_screen_effect_mgt')
@onready var enemy_movement_targets = get_node('enemy_movement_targets')
@onready var sound_mgt = get_node('/root/main/sound_mgt')

var rotation_target: Vector3 = Vector3.ZERO

@export var movement_speed = 5.0
var kick_force = 900.0
var mouse_sensitivity = 500.0

var mouse_captured := true
var movement_velocity: Vector3
var input_mouse: Vector2
var input_enabled = true;
var immune_to_kick = []

func _ready() -> void:
	add_to_group('player')

func _physics_process(delta):
	handle_controls(delta)

	if not input_enabled:
		return;
	
	# Movement

	var applied_velocity: Vector3

	movement_velocity = transform.basis * movement_velocity # Move forward	
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)		
	velocity = applied_velocity
	move_and_slide()

	# Rotation
	
	head.rotation.z = lerp_angle(head.rotation.z, -input_mouse.x * 5 * delta, delta * 50)	
	# head.rotation.x = lerp_angle(head.rotation.x, rotation_target.x, delta * 25)
	rotation.y = lerp_angle(rotation.y, rotation_target.y, delta * 25)

func _process(_delta):
	if animation.kick_connecting:
		for node in main.get_nodes_in_shape(kick_detector):
			if not node in immune_to_kick:
				immune_to_kick.append(node)
				if node.is_in_group('kickable'):
					node.kick(global_position, kick_force)
					sound_mgt.play_sound(node, 'kick')


func handle_controls(_delta):
	if not input_enabled:
		return;
	
	# Mouse capture
	
	if Input.is_action_just_pressed("mouse_capture"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_captured = true
	
	if Input.is_action_just_pressed("mouse_capture_exit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_captured = false
		
		input_mouse = Vector2.ZERO
	
	# Movement
	
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")	
	movement_velocity = Vector3(input.x, 0, input.y).normalized() * movement_speed

	# Kicking
	
	if Input.is_action_just_pressed("kick") and animation.current_animation != 'kick':
		immune_to_kick = []
		animation.play('kick')


func take_damage():
	full_screen_effect_mgt.flash_black()

	
func _input(event):
	if not input_enabled:
		return;

	if event is InputEventMouseMotion and mouse_captured:
		
		input_mouse = event.relative / mouse_sensitivity
		
		rotation_target.y -= event.relative.x / mouse_sensitivity
		rotation_target.x -= event.relative.y / mouse_sensitivity

func get_valid_enemy_movement_targets():
	return enemy_movement_targets.get_valid_targets()
