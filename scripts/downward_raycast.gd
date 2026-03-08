extends RayCast3D

var valid = false
var movement_position = Vector3.ZERO


func _physics_process(_delta: float) -> void:
	valid = false
	movement_position = Vector3.ZERO
	if not is_colliding():
		return

	var current_result = null
	current_result = get_collider()
	if current_result == null:
		return

	if current_result.is_in_group('navgrid'):
		valid = true
		movement_position = get_collision_point()
