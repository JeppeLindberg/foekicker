extends Control

@export var player: Node3D

@export var radius = 150

@onready var center = get_node('center')
@onready var animation = player.get_node('animation')

var width = 10

func _process(_delta: float) -> void:	
	queue_redraw()


func _draw() -> void:
	var color = Color.AQUAMARINE
	if animation.kick_connecting:
		color = Color.RED

	var calc_radius = radius
	calc_radius -= animation.kick_lifetime * 50.0

	draw_arc(center.global_position, calc_radius, 0, 360, 80, color ,width * animation.ui_visibility,true)
	# draw_circle(center.global_position,10,Color.RED)
