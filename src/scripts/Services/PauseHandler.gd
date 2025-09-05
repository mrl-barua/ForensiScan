extends Control

@onready var pause_button: TextureButton = $PauseButton
@onready var pause_menu: ColorRect = $PauseMenu

var is_paused: bool = false

func _ready():
	pause_menu.hide()
	# Set this node to process even when paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC key
		toggle_pause()

func _on_pause_button_pressed():
	toggle_pause()

func _on_continue_button_pressed():
	toggle_pause()

func _on_exit_button_pressed():
	# Resume the game before changing scenes
	if ApplicationManager.is_paused():
		ApplicationManager.resume()
	# Go back to main menu
	get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn")

func toggle_pause():
	ApplicationManager.pause_play()
	is_paused = ApplicationManager.is_paused()
	
	if is_paused:
		pause_button.hide()
		pause_menu.show()
		# Pause any video playback if present
		_pause_video_if_present()
		# Pause any typewriters if present
		_pause_typewriters_if_present()
	else:
		pause_button.show()
		pause_menu.hide()
		# Resume any video playback if present
		_resume_video_if_present()
		# Resume any typewriters if present
		_resume_typewriters_if_present()

func _pause_video_if_present():
	# Look for VideoPlayback components in the scene
	var video_players = get_tree().get_nodes_in_group("video_players")
	for player in video_players:
		if player.has_method("pause"):
			player.pause()

func _resume_video_if_present():
	# Look for VideoPlayback components in the scene
	var video_players = get_tree().get_nodes_in_group("video_players")
	for player in video_players:
		if player.has_method("resume"):
			player.resume()

func _pause_typewriters_if_present():
	# Look for Typewriter components in the scene
	var typewriters = get_tree().get_nodes_in_group("typewriters")
	for typewriter in typewriters:
		if typewriter.has_method("pause_typing"):
			typewriter.pause_typing()

func _resume_typewriters_if_present():
	# Look for Typewriter components in the scene
	var typewriters = get_tree().get_nodes_in_group("typewriters")
	for typewriter in typewriters:
		if typewriter.has_method("resume_typing"):
			typewriter.resume_typing()
