@tool
extends WorldEnvironment

@export var editor_environment: Environment
@export var play_mode_environment: Environment
@export var force_play_mode_env = false


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint() or force_play_mode_env:
		environment = play_mode_environment		
	else:
		environment = editor_environment
		


