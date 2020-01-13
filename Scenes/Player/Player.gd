extends KinematicBody2D

const X_SPEED = 100
const Y_SPEED = 100

var active = true
var health = 100
var velocity = Vector2()
var direction = 1
var current_state = 0
var is_dead = false
var has_second_chance = true

func _ready():
	pass

# Handles the Physics step for the player
func _physics_process(delta):
	pollInput()
	move()
	
# Handles input for the player
func pollInput():
	# Handle movement on X Axis
	if Input.is_action_pressed("ui_right"):
		direction = 1
		velocity.x = X_SPEED
		$Sprite.flip_h = false
	elif Input.is_action_pressed("ui_left"):
		direction = -1
		velocity.x = -X_SPEED
		$Sprite.flip_h = true
	else:
		velocity.x = 0
	
	# Handle movement on Y Axis
	if Input.is_action_pressed("ui_up"):
		velocity.y = -Y_SPEED
	elif Input.is_action_pressed("ui_down"):
		velocity.y = Y_SPEED
	else:
		velocity.y = 0
		
func move():
	velocity = move_and_slide(velocity)