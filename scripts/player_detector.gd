extends Node3D


@onready var raycast:RayCast3D = get_node('raycast')
@onready var player = get_node('/root/main/player')

var detecting_player = false


func _process(_delta: float) -> void:
	raycast.global_position = global_position
	raycast.target_position = player.global_position - raycast.global_position

	if raycast.global_position.distance_to(raycast.target_position) > 11.0:
		detecting_player = false

	var node = raycast.get_collider()
	if node != null and node.is_in_group('player'):
		detecting_player = true
	else:
		detecting_player = false



