extends Node2D

const Key = preload("res://Scenes/Second Chance/Key.tscn")
const cirlce_r = 50

var circle_pos = Vector2(0, 0)
var angle = 0
var poolvec2 = PoolVector2Array()
var items = 5
var line_thickness = 4
var line_color = Color.gray
var aa = true
enum KEYS {
	W,
	A,
	S,
	D
}

var key_list = []
var key_instances = []
var key_index = 0
var failed = false
var second_chance_timer_offset = -1

var timer_value = 100
var starting_position = Vector2()
var min_angle = -1.6
var max_angle = 4.7
var current_angle

var second_chance_timer_length

func _ready():
	second_chance_timer_length = $SecondChanceTimer.wait_time
	#start()		# Execute to run in its own scene
	pass

func stop():
	self.set_process(false)
	self.set_physics_process(false)
	self.set_process_input(false)
	self.hide()
	
func start():
	key_index = 0
	failed = false
	
	self.set_process(true)
	self.set_physics_process(true)
	self.set_process_input(true)
	
	randomize()
	show()
	calculate_points()
	select_inputs()
	place_keys()
	updateTimerBar()
	$SecondChanceTimer.start(second_chance_timer_offset)
	
func place_keys():
	for key in key_instances:
		key.queue_free()
	key_instances.clear()
	
	for index in key_list.size():
		var new_key = Key.instance()
		new_key.setOffsetIndex(KEYS[key_list[index]])
		new_key.position = poolvec2[index]
		key_instances.append(new_key)
		add_child(new_key)

func select_inputs():
	key_list = []
	
	key_list = []
	for i in items:
		key_list.append(KEYS.keys()[randi() % KEYS.size()])

# Handles the Physics step for the key
func _physics_process(delta):
	pollInput()
	updateTimerBar()
	
func updateTimerBar():
	var timer_left = $SecondChanceTimer.time_left
	timer_value = timer_left * (100/second_chance_timer_length)
	timer_value = clamp(timer_value, 0, 100)
	var value = ((min_angle * -1) + max_angle) / 100
	current_angle = max_angle - (timer_value * value)
	update()
	
func draw_timer_meter(pos, size, width, current, color):
	# Background
	draw_arc(pos, size, max_angle, min_angle, 800, Color(0, 0, 0, 0.5), width, true)
	
	draw_arc(pos, size, max_angle, current, 800, color, width, true)
	
# Handles polling input for the key
func pollInput():
	var key
	if !failed:
		if Input.is_action_just_pressed("ui_up"):
			check_key("W")
		elif Input.is_action_just_pressed("ui_down"):
			check_key("S")
		elif Input.is_action_just_pressed("ui_left"):
			check_key("A")
		elif Input.is_action_just_pressed("ui_right"):
			check_key("D")

func success():
	print("SecondChance: Success")
	emit_signal("Second Chance Success")
	self.hide()
	
func failed():
	print("SecondChance: Failed")
	emit_signal("Second Chance Failed")

func check_key(pressed_key):
	var current_key = key_list[key_index]
	if current_key == pressed_key:
		var c = key_instances[key_index]
		key_instances[key_index].pass_action()
		key_index += 1
	else:
		key_instances[key_index].fail_action()
		failed = true
		$Timer.start()
		
	if key_index == key_instances.size():
		success()

func _draw():
	draw_timer_meter(circle_pos, 40, 30, current_angle, Color('#71e958'))
	
	# Draw shape
	draw_polyline(poolvec2, line_color, line_thickness, aa)
	
func calculate_points():
	var first = true
	var radius = cirlce_r - 10
	poolvec2 = PoolVector2Array()
	
	for i in items:
		# Find angle
		var x = circle_pos.x + radius * cos(2 * PI * i / items)
		var y = circle_pos.y + radius * sin(2 * PI * i / items)
		
		var position
		if first:
			first = false
			calculate_angle(Vector2(x, y))
		position = rotate_point_by_angle(Vector2(x, y), -angle)
		poolvec2.append(position)
	
	# To complete the loop
	poolvec2.append(poolvec2[0])

func calculate_angle(point):
	var first_point = Vector2(circle_pos.x, circle_pos.y - cirlce_r)
	var vec1 = Vector2(circle_pos.x - first_point.x, circle_pos.y - first_point.y)
	var vec2 = Vector2(circle_pos.x - point.x,  circle_pos.y - point.y)
	
	var mag1 = sqrt(vec1.x * vec1.x + vec1.y * vec1.y)
	var mag2 = sqrt(vec2.x * vec2.x + vec2.y * vec2.y)
	
	var dot_product = vec1.dot(vec2)
	angle = acos(dot_product/ mag1 * mag2)
	# Rotate point by angle
	return rotate_point_by_angle(point, -angle)
	
func rotate_point_by_angle(point, angle):
	var x = point.x * cos(angle) - point.y * sin(angle)
	var y = point.y * cos(angle) + point.x * sin(angle)
	
	x = cos(angle) * (point.x - circle_pos.x) - sin(angle) * (point.y - circle_pos.y) + circle_pos.x
	y = sin(angle) * (point.x - circle_pos.x) - cos(angle) * (point.y - circle_pos.y) + circle_pos.y
	
	return Vector2(x, y)

func _on_Timer_timeout():
	key_instances[key_index].reset_action()
	if key_index <= 0:
		key_index = 0
		failed = false
	else:
		$Timer.start()
		key_index -= 1
	
func _on_SecondChanceTimer_timeout():
	failed()
