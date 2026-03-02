extends Node

@export var full_screen_effect: Panel
@export var transition_anim: AnimationPlayer

@export var black: Color
@export var transparent: Color

var color_A = null
var color_B = null

@export var blend = 0.0


func flash_black():
	color_A = black
	color_B = transparent
	transition_anim.play('transition')


func _process(_delta: float) -> void:
	if color_A != null and color_B != null:
		full_screen_effect.self_modulate = lerp(color_A, color_B, blend)
