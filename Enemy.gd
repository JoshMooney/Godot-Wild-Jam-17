extends KinematicBody2D

export(float) var SPEED = 80.0
const DASH_BOOST = 40

enum STATES {
	IDLE,
	FOLLOW,
	DEAD,
	ATTACK
}
var _state = null
var attack_damage = 20
var is_attacking = false
var is_moving = false
var direction = -1
var velocity = Vector2(0, 0)
var health = 50
var alive = true
var is_ingaged = false

var target_point_world = Vector2()
var target_position = Vector2()
var path = []

var calculatePathTimer
export(int) var calculatePathTimerValue = 3

func _ready():
	createCalculatePathTimer()
	_change_state(STATES.IDLE)
	
func _physics_process(delta):
	if alive:
		process_astar()
		
		if velocity.x > 0:
			$AnimatedSprite.flip_h = true
		elif velocity.x < 0:
			$AnimatedSprite.flip_h = false

func _change_state(new_state):
	if new_state == STATES.FOLLOW:
		path = get_parent().get_node("GroundTileMap").find_path(position, target_position)
		if not path or len(path) == 1:
			_change_state(STATES.IDLE)
			return
		# The index 0 is the starting cell
		# we don't want the character to move back to it in this example
		target_point_world = path[1]
	_state = new_state

func process_astar():
	if not _state == STATES.FOLLOW:
		return
	var arrived_to_next_point = move_to(target_point_world)
	if arrived_to_next_point:
		path.remove(0)
		if len(path) == 0:
			next_state()
			return
		target_point_world = path[0]
		
func next_state():
	if is_ingaged:
		searchDetectionAreaForPlayer()
	else:
		_change_state(STATES.IDLE)
		print("Enemy Doesn't know what to do next, returning to IDLE")
func move_to(world_position):
	var ARRIVE_DISTANCE = 10.0

	velocity = (world_position - position).normalized() * SPEED
	position += velocity * get_process_delta_time()
	
	return position.distance_to(world_position) < ARRIVE_DISTANCE
	
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
	alive = false
	_change_state(STATES.DEAD)
	$AnimatedSprite.play("death")
	$Hitbox.disabled = true

func createCalculatePathTimer():
	calculatePathTimer = Timer.new()
	calculatePathTimer.connect("timeout", self, "_on_calculatePathTimer_timeout") 
	calculatePathTimer.set_wait_time(calculatePathTimerValue)
	add_child(calculatePathTimer)
	calculatePathTimer.start()

func searchDetectionAreaForPlayer():
	var bodies = $DetectionArea.get_overlapping_bodies()
	for body in bodies:
		if handleCollision(body):
			print("Updated Player Position")
			break

func _on_calculatePathTimer_timeout():
	searchDetectionAreaForPlayer()
	
func handleCollision(body):
	if body.is_in_group("Player"):
		calculatePathTimer.start()
		target_position = body.get_position()
		_change_state(STATES.FOLLOW)
		return true
	return false

func _on_DetectionArea_body_entered(body):
	is_ingaged = true
	if handleCollision(body):
		print("Player Found")

func _on_DetectionArea_body_exited(body):
	if body.is_in_group("Player"):
		is_ingaged = false
		_change_state(STATES.IDLE)
		path.empty()
		print("Player Lost")
	pass
