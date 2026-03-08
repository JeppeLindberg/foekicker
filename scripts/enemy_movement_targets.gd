@tool
extends Node3D


@export var distance_from_player = 5.0
@export var n_gon = 16
@export var downward_raycasts_prefab: PackedScene 
@export var player_head_to_ground = Vector3.DOWN * 0.48

@export_tool_button("Recreate", "Callable") var recreate_callable = recreate

func _ready() -> void:
	if not Engine.is_editor_hint():
		recreate()

func recreate():
	for child in get_children():
		child.queue_free()
	
	var forward_vec = Vector3.BACK * distance_from_player

	for i in range(n_gon):
		var new_target = forward_vec.rotated(Vector3.UP, deg_to_rad(360.0 * (i / float(n_gon)))) + player_head_to_ground
		var new_raycast = downward_raycasts_prefab.instantiate()		
		add_child(new_raycast)
		new_raycast.owner = get_tree().edited_scene_root
		new_raycast.position = Vector3.ZERO
		new_raycast.target_position = new_target * 2.0
		var gizmo = new_raycast.get_child(0)
		gizmo.position = new_target


func get_valid_targets():
	var results = []
	for child in get_children():
		if child.valid:
			results.append(child.get_child(0))
	return results
