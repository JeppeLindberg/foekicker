extends Node


@export var sound_player_prefab: PackedScene

@export var kick_stream: AudioStream


func play_sound(node, sound_name):
	var new_sound_player: AudioStreamPlayer3D = sound_player_prefab.instantiate()
	node.add_child(new_sound_player)
	new_sound_player.global_position = node.global_position
	match sound_name:
		'kick':
			new_sound_player.stream = kick_stream
			new_sound_player.pitch_scale = randf_range(0.7, 2.0)
	new_sound_player.play()
