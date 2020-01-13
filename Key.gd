extends Sprite

const KEYBOARD = 0
const CONTROLLER = 1
const TILESIZE = 32

enum STATE {
	PASS,
	FAIL,
	NIL
}
var current_state = STATE.NIL
var inputType = KEYBOARD
var keyIndex

func _ready():
	pass 

func setOffsetIndex(index):
	keyIndex = index
	var rect = Rect2(keyIndex * TILESIZE, inputType * TILESIZE, TILESIZE, TILESIZE)
	self.set_region_rect(rect)

func reset_action():
	current_state = STATE.NIL
	$Pass.hide()
	$Fail.hide()
	
func pass_action():
	current_state = STATE.PASS
	$Pass.show()
	$Fail.hide()
	
func fail_action():
	current_state = STATE.FAIL
	$Pass.hide()
	$Fail.show()
