extends Node2D

var health = 100
var health_decay = 100
var mana = 100
var bob_limits = Vector2(0, 10)
var bob_direction = 1
var starting_position = Vector2()

var pos = Vector2(0, 0)
var current_angle = -1.6

var min_angle = -1.6
var max_angle = 4.7
var decay_speed = 0.5
export var health_scale = 100

func _ready():
	starting_position = pos

func _draw():
	#draw_arc(center: Vector2, radius: float, start_angle: float, end_angle: float, point_count: int, color: Color, width: float = 1.0, antialiased: bool = false)
	#draw_arc(pos, 40, 4.7, -1.6, 800, Color('#71e958'), 37, true)
	draw_health_meter(pos, 40 / health_scale, 37 / health_scale, get_current_angle(health), Color('#71e958'))
	
	# Draw Mana Meter
	draw_mana_meter(pos, 70 / health_scale, 11 / health_scale, 2, Color('#49E0FF'))
	#draw_mana_meter(pos, 70 / health_scale, 11 / health_scale, get_current_angle(health), Color('#49E0FF'))
	pass
	
func draw_health_meter(pos, size, width, current, color):
	# Background
	draw_arc(pos, size, max_angle, min_angle, 800, Color(0, 0, 0, 0.5), width, true)
	draw_arc(pos, size, max_angle, get_current_angle(health_decay), 800, Color('FF3D50'), width, true)
	draw_arc(pos, size, max_angle, current, 800, color, width, true)
	
func draw_mana_meter(pos, size, width, current, color):
	# Background
	draw_arc(pos, size, max_angle, min_angle, 800, Color(0, 0, 0, 0.5), width, true)
	
	draw_arc(pos, size, max_angle, current, 800, color, width, true)

func set_values(m, h):
	mana = m
	health = h
	update()
	
func get_current_angle(v):
	v = clamp(v, 0, 100)
	var value = ((min_angle * -1) + max_angle) / 100
	return max_angle - (v * value)

func _physics_process(delta):
	bob()
	update()
	if health < health_decay:
		health_decay -= decay_speed
	if health > health_decay:
		health_decay = health
#	# Debugging features
#	if Input.is_action_pressed("ui_accept"):
#		health += 10
#		set_values(mana, health)
#	if Input.is_action_just_pressed("ui_focus_next"):
#		health -= 10
#		set_values(mana, health)
#	if Input.is_action_pressed("ui_accept") || Input.is_action_pressed("ui_focus_next"):
#		update()

# Create a bobing effect for following the player
func bob():
	var stages = 40
	pos += bob_direction * (bob_limits/stages)
	if pos.y < starting_position.y - bob_limits.y:
		bob_direction = -bob_direction
	if pos.y > starting_position.y + bob_limits.y:
		bob_direction = -bob_direction
	pass
