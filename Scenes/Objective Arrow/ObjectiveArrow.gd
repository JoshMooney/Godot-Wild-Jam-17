extends Node2D

var current_objective = Vector2(0, 0)
var distance = 5
var direction = Vector2()
var starting_position = Vector2()
onready var arrowSprite = get_node("ArrowSprite")

func _ready():
	starting_position = get_position()

func set_objective(obj):
	current_objective = obj

func _physics_process(delta):
	update()
	pass
	
func update():
	#arrowSprite.set_position(starting_position)
	#current_objective = get_global_mouse_position()
	arrowSprite.look_at(current_objective)
	
	# Move
	
	position = get_position()
	var normalized_vector = normalize(Vector2(current_objective.x - position.x, current_objective.y - position.y))
	direction = normalized_vector
	
func normalize(vec):
	var dir 
	var mag = sqrt(vec.x*vec.x + vec.y*vec.y)
	if mag > 0:
		dir = Vector2(vec.x/mag, vec.y/mag)
	return dir
