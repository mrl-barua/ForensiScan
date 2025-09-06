extends Control

# Enhanced Pause Handler
# Modern UI/UX with improved animations and functionality

# Node references for the new UI structure
# UI component references
@onready var pause_button: TextureButton = $PauseButton
@onready var pause_menu: Control = $PauseMenu
@onready var menu_panel: Panel = $PauseMenu/CenterContainer/MenuPanel
@onready var pause_background: ColorRect = $PauseBackground
@onready var continue_button = $PauseMenu/CenterContainer/MenuPanel/ContentContainer/ButtonSection/ContinueButton
@onready var restart_button = $PauseMenu/CenterContainer/MenuPanel/ContentContainer/ButtonSection/RestartButton
@onready var exit_button = $PauseMenu/CenterContainer/MenuPanel/ContentContainer/ButtonSection/ExitButton
@onready var progress_label: Label = $PauseMenu/CenterContainer/MenuPanel/ContentContainer/InfoSection/InfoPanel/InfoContent/ProgressLabel
@onready var tip_label: Label = $PauseMenu/CenterContainer/MenuPanel/ContentContainer/InfoSection/InfoPanel/InfoContent/TipLabel

# Animation and state management
var is_paused: bool = false
var entrance_tween: Tween
var button_tweens: Dictionary = {}
var current_scene_name: String = ""

func _ready():
	setup_initial_state()
	setup_animations()
	setup_button_connections()
	update_progress_info()
	
	# Set this node to process even when paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func setup_initial_state():
	"""Initialize the pause screen state"""
	pause_menu.hide()
	pause_background.hide()
	
	# Set initial state for animations - don't touch position
	menu_panel.modulate.a = 0.0
	menu_panel.scale = Vector2(0.8, 0.8)
	pause_background.modulate.a = 0.0
	
	# Ensure MenuPanel position is not modified from its anchor settings
	# The scene should handle centering via anchors

func setup_animations():
	"""Setup entrance animations and effects"""
	# Setup pause button hover effects
	pause_button.mouse_entered.connect(_on_pause_button_hover)
	pause_button.mouse_exited.connect(_on_pause_button_unhover)

func setup_button_connections():
	"""Connect all button signals and setup hover effects"""
	# Connect button signals
	continue_button.pressed.connect(_on_continue_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	
	# Setup hover effects for all buttons
	var buttons = [continue_button, restart_button, exit_button]
	for button in buttons:
		setup_button_hover_effects(button)

func setup_button_hover_effects(button: Button):
	"""Setup modern hover effects for buttons"""
	button.mouse_entered.connect(_on_menu_button_hover.bind(button))
	button.mouse_exited.connect(_on_menu_button_unhover.bind(button))

func update_progress_info():
	"""Update the progress information display"""
	# Get current scene name for progress display
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene_name = current_scene.scene_file_path.get_file().get_basename()
		
		# Format progress text based on scene
		if "Quiz" in current_scene_name:
			progress_label.text = "📝 Currently in: Quiz Mode"
		elif "Lesson" in current_scene_name:
			progress_label.text = "📚 Currently in: Lesson Mode"
		elif "Video" in current_scene_name:
			progress_label.text = "🎥 Currently watching: Video Content"
		else:
			progress_label.text = "🎓 ForensiScan Learning Platform"
	
	# Rotate tips
	var tips = [
		"💡 Tip: Press ESC to pause/resume anytime",
		"💡 Tip: Your progress is automatically saved",
		"💡 Tip: Take breaks to improve retention",
		"💡 Tip: Review previous lessons if needed"
	]
	tip_label.text = tips[randi() % tips.size()]

func _input(event):
	"""Handle input events"""
	if event.is_action_pressed("ui_cancel"):  # ESC key
		toggle_pause()

func _on_pause_button_hover():
	"""Pause button hover animation"""
	if button_tweens.has("pause_button"):
		button_tweens["pause_button"].kill()
	
	button_tweens["pause_button"] = create_tween()
	var tween = button_tweens["pause_button"]
	tween.set_parallel(true)
	tween.tween_property(pause_button, "scale", Vector2(0.65, 0.65), 0.15).set_trans(Tween.TRANS_BACK)
	tween.tween_property(pause_button, "rotation", deg_to_rad(5), 0.15).set_trans(Tween.TRANS_SINE)

func _on_pause_button_unhover():
	"""Pause button unhover animation"""
	if button_tweens.has("pause_button"):
		button_tweens["pause_button"].kill()
	
	button_tweens["pause_button"] = create_tween()
	var tween = button_tweens["pause_button"]
	tween.set_parallel(true)
	tween.tween_property(pause_button, "scale", Vector2(0.6, 0.6), 0.15).set_trans(Tween.TRANS_BACK)
	tween.tween_property(pause_button, "rotation", 0.0, 0.15).set_trans(Tween.TRANS_SINE)

func _on_menu_button_hover(button: Button):
	"""Enhanced menu button hover effect"""
	var button_id = button.get_instance_id()
	if button_tweens.has(button_id):
		button_tweens[button_id].kill()
	
	button_tweens[button_id] = create_tween()
	var tween = button_tweens[button_id]
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1.02, 1.02), 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property(button, "rotation", deg_to_rad(0.5), 0.2).set_trans(Tween.TRANS_SINE)

func _on_menu_button_unhover(button: Button):
	"""Enhanced menu button unhover effect"""
	var button_id = button.get_instance_id()
	if button_tweens.has(button_id):
		button_tweens[button_id].kill()
	
	button_tweens[button_id] = create_tween()
	var tween = button_tweens[button_id]
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property(button, "rotation", 0.0, 0.2).set_trans(Tween.TRANS_SINE)

func _on_pause_button_pressed():
	"""Handle pause button press with feedback animation"""
	# Add click feedback
	if button_tweens.has("pause_click"):
		button_tweens["pause_click"].kill()
	
	button_tweens["pause_click"] = create_tween()
	var tween = button_tweens["pause_click"]
	tween.tween_property(pause_button, "scale", Vector2(0.55, 0.55), 0.05)
	tween.tween_property(pause_button, "scale", Vector2(0.6, 0.6), 0.05)
	
	toggle_pause()

func toggle_pause():
	"""Toggle pause state with enhanced animations"""
	ApplicationManager.pause_play()
	is_paused = ApplicationManager.is_paused()
	
	if is_paused:
		await show_pause_menu()
		# Pause any media content
		pause_media_content()
	else:
		await hide_pause_menu()
		# Resume any media content
		resume_media_content()

func show_pause_menu():
	"""Show pause menu with smooth animations"""
	update_progress_info()  # Update info when showing menu
	
	pause_button.hide()
	pause_background.show()
	pause_menu.show()
	
	# Reset initial state for smooth animation
	pause_background.modulate.a = 0.0
	menu_panel.modulate.a = 0.0
	menu_panel.scale = Vector2(0.7, 0.7)
	
	# CenterContainer will handle centering automatically
	
	if entrance_tween:
		entrance_tween.kill()
	
	entrance_tween = create_tween()
	entrance_tween.set_parallel(true)
	
	# Animate background
	entrance_tween.tween_property(pause_background, "modulate:a", 1.0, 0.4)
	
	# Animate menu panel with smooth scale and fade only
	entrance_tween.tween_property(menu_panel, "modulate:a", 1.0, 0.5).set_delay(0.1)
	entrance_tween.tween_property(menu_panel, "scale", Vector2(1.0, 1.0), 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.1)
	
	# Animate buttons with staggered timing
	var buttons = [continue_button, restart_button, exit_button]
	for i in range(buttons.size()):
		var button = buttons[i]
		button.modulate.a = 0.0
		button.scale = Vector2(0.8, 0.8)
		var delay = 0.3 + (i * 0.1)
		
		entrance_tween.tween_property(button, "modulate:a", 1.0, 0.3).set_delay(delay)
		entrance_tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(delay)
	
	await entrance_tween.finished

func hide_pause_menu():
	"""Hide pause menu with smooth animations"""
	if entrance_tween:
		entrance_tween.kill()
	
	entrance_tween = create_tween()
	entrance_tween.set_parallel(true)
	
	# Animate menu panel out with scale and fade only
	entrance_tween.tween_property(menu_panel, "modulate:a", 0.0, 0.3)
	entrance_tween.tween_property(menu_panel, "scale", Vector2(0.7, 0.7), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	# Animate background out
	entrance_tween.tween_property(pause_background, "modulate:a", 0.0, 0.4).set_delay(0.1)
	
	await entrance_tween.finished
	
	pause_background.hide()
	pause_menu.hide()
	pause_button.show()
	
	# Don't manipulate position - let anchors handle centering

func pause_media_content():
	"""Pause any media content in the scene"""
	# Pause video players
	var video_players = get_tree().get_nodes_in_group("video_players")
	for player in video_players:
		if player.has_method("pause"):
			player.pause()
	
	# Pause typewriters
	var typewriters = get_tree().get_nodes_in_group("typewriters")
	for typewriter in typewriters:
		if typewriter.has_method("pause_typing"):
			typewriter.pause_typing()
	
	# Pause any timers or animations
	var timers = get_tree().get_nodes_in_group("pausable_timers")
	for timer in timers:
		if timer.has_method("pause"):
			timer.pause()

func resume_media_content():
	"""Resume any media content in the scene"""
	# Resume video players
	var video_players = get_tree().get_nodes_in_group("video_players")
	for player in video_players:
		if player.has_method("resume"):
			player.resume()
	
	# Resume typewriters
	var typewriters = get_tree().get_nodes_in_group("typewriters")
	for typewriter in typewriters:
		if typewriter.has_method("resume_typing"):
			typewriter.resume_typing()
	
	# Resume any timers or animations
	var timers = get_tree().get_nodes_in_group("pausable_timers")
	for timer in timers:
		if timer.has_method("start"):
			timer.start()

# Button press handlers
func _on_continue_button_pressed():
	"""Handle continue button press"""
	print("Resuming game...")
	toggle_pause()

func _on_restart_button_pressed():
	"""Handle restart button press"""
	print("Restarting current lesson...")
	# Resume the game before changing scenes
	if ApplicationManager.is_paused():
		ApplicationManager.resume()
	
	# Reload current scene
	get_tree().reload_current_scene()

func _on_exit_button_pressed():
	"""Handle exit button press"""
	print("Returning to main menu...")
	# Resume the game before changing scenes
	if ApplicationManager.is_paused():
		ApplicationManager.resume()
	
	# Go back to main menu
	get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn")
