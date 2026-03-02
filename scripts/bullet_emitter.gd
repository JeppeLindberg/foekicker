extends Node3D

@onready var main = get_node('/root/main')

@export var bullet_prefab: PackedScene

@export var bullets_per_min = 20.0

var emission_timer = 0.0
var emitting = true


func _process(delta: float) -> void:
	if not emitting:
		emission_timer = 0.0
		return

	emission_timer += delta * (bullets_per_min / 60.0)

	if emission_timer > 1.0:
		emission_timer -= 1.0

		emit()


func emit():
	var new_bullet = bullet_prefab.instantiate()
	main.add_child(new_bullet)
	new_bullet.global_position = global_position
	new_bullet.forward = -global_transform.basis.z
