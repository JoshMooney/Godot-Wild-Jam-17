extends KinematicBody2D

const X_SPEED = 100
const Y_SPEED = 100

var alive = true
var active = true
var health = 100
var velocity = Vector2()
var direction = 1
var current_state = 0
var is_dead = false
var has_second_chance = true
var second_chance_active = false
var second_chance_hp = 20
var looking_diection = Vector2(0, 0)

var is_attacking = false
var can_attack = true
var player_damage = 50
var objective_arrow_distance_scaler = 1000

func _ready():
	$DeathAnimation.hide()
	$HealthMeter.set_values(100, health)
	$SecondChance.stop()
	$AnimatedSprite.play("idle")
	
	$Attack/Down_CollisionShape2D.disabled = true
	$Attack/Up_CollisionShape2D.disabled = true
	$Attack/Horizontal_CollisionShape2D.disabled = true
	pass

# Handle Second chance failed 
func _on_second_chance_failed():
	second_chance_active = false
	die()

func respawn(): 
	health = 100
	alive = true

# Handle Second Chance Successful 
func _on_second_chance_success():
	second_chance_active = false
	health += second_chance_hp
	$HealthMeter.set_values(100, health)
	$SecondChance.increase_difficulty()
	print('Second Chance Successful')

# Handles the Physics step for the player
func _physics_process(delta):
	if alive:
		pollInput()
		move()
	
# Handles input for the player
func pollInput():
	if !second_chance_active && !is_attacking:
		# Handle movement on X Axis
		if Input.is_action_pressed("ui_right"):
			direction = 1
			velocity.x = X_SPEED
			$AnimatedSprite.play("run_right")
			looking_diection = Vector2(1, 0)
		elif Input.is_action_pressed("ui_left"):
			direction = -1
			velocity.x = -X_SPEED
			$AnimatedSprite.play("run_left")
			looking_diection = Vector2(-1, 0)
		else:
			velocity.x = 0
			
			
		# Handle movement on Y Axis
		if Input.is_action_pressed("ui_up"):
			velocity.y = -Y_SPEED
			#$AnimatedSprite.play("run_up")
			looking_diection = Vector2(0, -1)
		elif Input.is_action_pressed("ui_down"):
			velocity.y = Y_SPEED
			#$AnimatedSprite.play("run_down")
			looking_diection = Vector2(0, 1)
		else:
			velocity.y = 0
		
		if Input.is_action_just_pressed("ui_select"):
			velocity = Vector2(0, 0)
			attack()
		$ObjectiveArrow.set_objective(looking_diection * objective_arrow_distance_scaler)
	
	if velocity == Vector2(0, 0) && !is_attacking:
		$AnimatedSprite.play("idle")
		
	if Input.is_action_just_pressed("ui_accept"):
		hit(10)
		
func move():
	velocity = move_and_slide(velocity)
	

func attack():
	is_attacking = true
	if looking_diection.x != 0:
		$Attack/Horizontal_CollisionShape2D.disabled = false
		if looking_diection.x < 0:
			$AnimatedSprite.play("attack_right")
		elif looking_diection.x > 0:
			$AnimatedSprite.play("attack_left")
	elif looking_diection.y < 0:
		$Attack/Up_CollisionShape2D.disabled = false
		$AnimatedSprite.play("attack_up")
	elif looking_diection.y > 0:
		$Attack/Down_CollisionShape2D.disabled = false
		$AnimatedSprite.play("attack_down")

func hit(dmg):
	health -= dmg
	
	health = clamp(health,0, 99)
	$HealthMeter.set_values(100, health)
	if health == 0:
		if has_second_chance:
			second_chance_active = true
			$SecondChance.start()
		else:
			die()
			
func die():
	alive = false
	$AnimatedSprite.play("dead")
	$DeathAnimation.play("dead")
	$DeathAnimation.show()
	
	# Hide health meter
	# Disable Attack collision boxes
	$Hitbox/CollisionShape2D.disabled = true
	$Attack/Down_CollisionShape2D.disabled = true
	$Attack/Up_CollisionShape2D.disabled = true
	
	# Disable Foot and Hitbox Collision boxes
	$FeetColisionShape.disabled = true	

func _on_AttackTimer_timeout():
	can_attack = false

func _on_AnimatedSprite_animation_finished():
	if "attack_" in $AnimatedSprite.animation:
		$AttackTimer.start()
		$Attack/Down_CollisionShape2D.disabled = true
		$Attack/Up_CollisionShape2D.disabled = true
		$Attack/Horizontal_CollisionShape2D.disabled = true
		is_attacking = false

func _on_Attack_body_entered(body):
	if body.is_in_group("Enemy"):
		body.hit(player_damage)
