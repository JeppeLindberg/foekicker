extends Control

@export var player: Node3D

@export var radius = 150

@onready var center = get_node('center')
@onready var kick_timer = player.get_node('kick_timer')

var width = 10

func _process(_delta: float) -> void:	
	queue_redraw()


func _draw() -> void:
	var color = Color.AQUAMARINE
	if kick_timer.kick_connecting:
		color = Color.RED

	var calc_radius = radius
	calc_radius -= kick_timer.kick_lifetime * 50.0

	draw_arc(center.global_position, calc_radius, 0, 360, 80, color ,width * kick_timer.ui_visibility,true)
	# draw_circle(center.global_position,10,Color.RED)

