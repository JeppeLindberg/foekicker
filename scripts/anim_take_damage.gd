extends AnimationPlayer

@export var flash_white = false

@export var normal_visual: Node3D
@export var flash_white_visual: Node3D

func _process(_delta):
	if flash_white:
		normal_visual.visible = false
		flash_white_visual.visible = true
	else:
		normal_visual.visible = true
		flash_white_visual.visible = false
