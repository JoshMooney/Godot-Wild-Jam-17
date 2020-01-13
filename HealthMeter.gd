extends Node2D

var health = 100
var mana = 100
var bob_limits = Vector2(0, 10)
var bob_direction = 1
var starting_position = Vector2()

var pos = Vector2(200, 200)
var current_angle = -1.6

var min_angle = -1.6
var max_angle = 4.7

func _ready():
	starting_position = pos

func _draw():
	#draw_arc(center: Vector2, radius: float, start_angle: float, end_angle: float, point_count: int, color: Color, width: float = 1.0, antialiased: bool = false)
	#draw_arc(pos, 40, 4.7, -1.6, 800, Color('#71e958'), 37, true)
	draw_health_meter(pos, 40, 37, current_angle, Color('#71e958'))
	
	# Draw Mana Meter
	draw_health_meter(pos, 70, 11, 2, Color('#49E0FF'))
	pass
	
func draw_health_meter(pos, size, width, current, color):
	# Background
	draw_arc(pos, size, max_angle, min_angle, 800, Color(0, 0, 0, 0.5), width, true)
	
	draw_arc(pos, size, max_angle, current, 800, color, width, true)

func set_values(m, h):
	mana = m
	health = h
	
	health = clamp(health, 0, 100)
	var value = ((min_angle * -1) + max_angle) / 100
	current_angle = max_angle - (health * value)
	
	update()

# Debuging functionality
func _process(delta):
	bob()
	update()
#	if Input.is_action_pressed("ui_up"):
#		health += 1
#	if Input.is_action_pressed("ui_down"):
#		health -= 1
#	if Input.is_action_pressed("ui_up") || Input.is_action_pressed("ui_down"):
#		update()
#

# Create a bobing effect for following the player
func bob():
	var stages = 40
	pos += bob_direction * (bob_limits/stages)
	if pos.y < starting_position.y - bob_limits.y:
		bob_direction = -bob_direction
	if pos.y > starting_position.y + bob_limits.y:
		bob_direction = -bob_direction
	pass
