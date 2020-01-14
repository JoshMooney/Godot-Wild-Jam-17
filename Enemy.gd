extends KinematicBody2D

const X_SPEED = 80
const Y_SPEED = 80
const DASH_BOOST = 40

enum FUNC {
	IDLE,
	MOVE,
	ATTACK
}
var attack_damage = 20
var is_attacking = false
var is_moving = false
var direction = -1
var velocity = Vector2(0, 0)
var health = 50

func _ready():
	pass
	
func _physics_process(delta):
	pass
	
func move():
	if velocity.x > 0:
		$AnimatedSprite.flip_h = true
	elif velocity.x < 0:
		$AnimatedSprite.flip_h = false
	
func attack():
	$AnimatedSprite.play("attack")
	# Find Target
	
	pass
	
func hit(dmg):
	health -= dmg
	if health <= 0 :
		die()
	print('Enemy Hit')
	
func die():
	$AnimatedSprite.play("death")
	$Hitbox.disabled = true

func _on_DetectionArea_body_entered(body):
	if body.is_in_group("Player"):
		print("Player Detected")
	pass


func _on_DetectionArea_body_exited(body):
	if body.is_in_group("Player"):
		print("Player Lost")
	pass
