extends Control

@onready var pause_button: TextureButton = $PauseButton
@onready var pause_menu: Panel = $PauseMenu
@onready var pause_background: ColorRect = $PauseBackground

var is_paused: bool = false
var tween: Tween

func _ready():
	pause_menu.hide()
	pause_background.hide()
	# Set this node to process even when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Add smooth hover effect to pause button
	pause_button.mouse_entered.connect(_on_pause_button_hover)
	pause_button.mouse_exited.connect(_on_pause_button_unhover)

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC key
		toggle_pause()

func _on_pause_button_hover():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(pause_button, "scale", Vector2(0.55, 0.55), 0.1)

func _on_pause_button_unhover():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(pause_button, "scale", Vector2(0.5, 0.5), 0.1)

func _on_pause_button_pressed():
	# Add click feedback
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(pause_button, "scale", Vector2(0.45, 0.45), 0.05)
	tween.tween_property(pause_button, "scale", Vector2(0.5, 0.5), 0.05)
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
		_show_pause_menu()
		# Pause any video playback if present
		_pause_video_if_present()
		# Pause any typewriters if present
		_pause_typewriters_if_present()
	else:
		_hide_pause_menu()
		# Resume any video playback if present
		_resume_video_if_present()
		# Resume any typewriters if present
		_resume_typewriters_if_present()

func _show_pause_menu():
	pause_button.hide()
	pause_background.show()
	pause_menu.show()
	
	# Animate pause menu appearance
	pause_menu.modulate.a = 0.0
	pause_menu.scale = Vector2(0.8, 0.8)
	pause_background.modulate.a = 0.0
	
	if tween:
		tween.kill()
	tween = create_tween().set_parallel(true)
	tween.tween_property(pause_background, "modulate:a", 1.0, 0.3)
	tween.tween_property(pause_menu, "modulate:a", 1.0, 0.3)
	tween.tween_property(pause_menu, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _hide_pause_menu():
	if tween:
		tween.kill()
	tween = create_tween().set_parallel(true)
	tween.tween_property(pause_background, "modulate:a", 0.0, 0.2)
	tween.tween_property(pause_menu, "modulate:a", 0.0, 0.2)
	tween.tween_property(pause_menu, "scale", Vector2(0.8, 0.8), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	await tween.finished
	pause_background.hide()
	pause_menu.hide()
	pause_button.show()

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
