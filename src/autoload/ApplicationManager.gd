extends Node

var paused: bool = false

func _ready():
	# Set process mode to always so this manager continues to work when paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func pause_play():
	paused = !paused
	get_tree().paused = paused
	
func resume():
	paused = false
	get_tree().paused = false
	
func pause():
	paused = true
	get_tree().paused = true
	
func is_paused() -> bool:
	return paused
