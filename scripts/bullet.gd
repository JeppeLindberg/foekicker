extends Area3D

@export var bullet_speed = 10.0

var forward



func _physics_process(delta: float) -> void:
	look_at(global_position + forward)
	global_position += -global_transform.basis.z * bullet_speed * delta



func _on_body_entered(body: Node3D) -> void:
	if is_queued_for_deletion():
		return
	
	if body.is_in_group('bullet_immune'):
		return

	if body.has_method('take_damage'):
		body.take_damage()

	queue_free()
