extends Node

var fsm: StateMachine

func enter():
	print("Hello from Move State")
	yield(get_tree().create_timer(2.0), "timeout")
	exit()

func exit():
	fsm.back()
