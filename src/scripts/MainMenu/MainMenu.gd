extends Node2D

# Enhanced Main Menu System
# Modern UI/UX with improved animations and layout

# Node references
@export var quit_button: Button
@onready var license_verifier: Control = $LicenseVerifier
@onready var main_container: HBoxContainer = $CanvasLayer/MainContainer
@onready var left_panel: VBoxContainer = $CanvasLayer/MainContainer/LeftPanel
@onready var right_panel: VBoxContainer = $CanvasLayer/MainContainer/RightPanel
@onready var menu_buttons: VBoxContainer = $CanvasLayer/MainContainer/RightPanel/MenuPanel/MainButtons
@onready var status_label: Label = $CanvasLayer/MainContainer/LeftPanel/InfoPanel/InfoContent/StatusLabel

# Animation tweens
var entrance_tween: Tween
var transition_tween: Tween
var button_tweens: Dictionary = {}  # Store individual tweens for each button

# Animation states
var is_animating: bool = false
var buttons_array: Array[Button] = []

func _ready() -> void:
	ApplicationManager.resume()
	setup_ui()
	check_license_status()

func check_license_status():
	"""Check license activation and show appropriate screen"""
	var license_verifier_script = preload("res://src/scripts/Services/LicenseVerifier.gd")
	if license_verifier_script.is_activated():
		license_verifier.get_node("CanvasLayer").hide()
		show_main_menu()
	else:
		license_verifier.get_node("CanvasLayer").show()
		hide_main_menu()

func setup_ui():
	"""Initialize UI components and collect button references"""
	collect_buttons()
	setup_button_connections()
	setup_initial_state()  # Now safe - keeps UI visible
	update_status_display()

func collect_buttons():
	"""Collect all interactive buttons for animation"""
	buttons_array.clear()
	
	# Get all buttons from the menu sections
	var lesson_section = $CanvasLayer/MainContainer/RightPanel/MenuPanel/MainButtons/LessonSection
	var assessment_section = $CanvasLayer/MainContainer/RightPanel/MenuPanel/MainButtons/AssessmentSection
	var quit_section = $CanvasLayer/MainContainer/RightPanel/MenuPanel/MainButtons/QuitSection
	
	for child in lesson_section.get_children():
		if child is Button:
			buttons_array.append(child)
	
	for child in assessment_section.get_children():
		if child is Button:
			buttons_array.append(child)
			
	for child in quit_section.get_children():
		if child is Button:
			buttons_array.append(child)

func setup_button_connections():
	"""Connect hover effects and interactions for all buttons"""
	for button in buttons_array:
		if button.mouse_entered.is_connected(_on_button_hover):
			button.mouse_entered.disconnect(_on_button_hover)
		if button.mouse_exited.is_connected(_on_button_unhover):
			button.mouse_exited.disconnect(_on_button_unhover)
			
		button.mouse_entered.connect(_on_button_hover.bind(button))
		button.mouse_exited.connect(_on_button_unhover.bind(button))

func setup_initial_state():
	"""Set initial visual state - keep UI visible by default"""
	# Keep main container visible by default
	main_container.modulate.a = 1.0
	main_container.visible = true
	
	# Reset panel positions to center
	left_panel.position.x = 0
	right_panel.position.x = 0
	
	# Set buttons to normal state and clean up any existing tweens
	reset_all_buttons()

func reset_all_buttons():
	"""Reset all buttons to their default state"""
	# Clear any existing button tweens
	for tween in button_tweens.values():
		if tween.is_valid():
			tween.kill()
	button_tweens.clear()
	
	# Reset button states
	for button in buttons_array:
		button.scale = Vector2(1.0, 1.0)
		button.modulate = Color(1.0, 1.0, 1.0, 1.0)
		button.rotation = 0.0

func update_status_display():
	"""Update status information"""
	var current_time = Time.get_datetime_string_from_system()
	status_label.text = "🟢 System Ready | " + current_time.split("T")[0]

func show_main_menu():
	"""Show main menu with entrance animations"""
	main_container.modulate.a = 1.0
	main_container.visible = true
	
	# Reset any transform changes
	left_panel.position.x = 0
	right_panel.position.x = 0
	
	# Make sure all buttons are visible and properly reset
	reset_all_buttons()
	
	# Optional: Play entrance animation if desired
	if not is_animating:
		animate_menu_entrance()

func hide_main_menu():
	"""Hide main menu"""
	main_container.modulate.a = 0.0
	main_container.visible = false

func animate_menu_entrance():
	"""Comprehensive entrance animation sequence"""
	if entrance_tween:
		entrance_tween.kill()
	
	entrance_tween = create_tween()
	entrance_tween.set_parallel(true)
	
	# Fade in main container
	entrance_tween.tween_property(main_container, "modulate:a", 1.0, 0.8)
	
	# Slide in panels from sides
	entrance_tween.tween_property(left_panel, "position:x", 0, 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	entrance_tween.tween_property(right_panel, "position:x", 0, 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Animate buttons with staggered timing
	for i in range(buttons_array.size()):
		var button = buttons_array[i]
		var delay = 0.3 + (i * 0.1)
		
		entrance_tween.tween_property(button, "modulate:a", 1.0, 0.5).set_delay(delay)
		entrance_tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(delay)
	
	# Complete animation callback
	entrance_tween.tween_callback(func(): is_animating = false).set_delay(1.5)

func _on_button_hover(button: Button):
	"""Enhanced button hover effect"""
	if is_animating:
		return
	
	# Get or create a unique tween for this button
	var button_id = button.get_instance_id()
	if button_tweens.has(button_id):
		button_tweens[button_id].kill()
	
	button_tweens[button_id] = create_tween()
	var tween = button_tweens[button_id]
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1.08, 1.08), 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property(button, "modulate", Color(1.1, 1.1, 1.1, 1.0), 0.2)
	
	# Add subtle rotation for extra flair
	tween.tween_property(button, "rotation", deg_to_rad(1), 0.2).set_trans(Tween.TRANS_SINE)

func _on_button_unhover(button: Button):
	"""Enhanced button unhover effect"""
	if is_animating:
		return
	
	# Get or create a unique tween for this button
	var button_id = button.get_instance_id()
	if button_tweens.has(button_id):
		button_tweens[button_id].kill()
	
	button_tweens[button_id] = create_tween()
	var tween = button_tweens[button_id]
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property(button, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
	tween.tween_property(button, "rotation", 0.0, 0.2).set_trans(Tween.TRANS_SINE)
	
	# Clean up the tween when done
	tween.finished.connect(func(): 
		if button_tweens.has(button_id):
			button_tweens.erase(button_id)
	)

func _process(delta):
	"""Continuous license status checking"""
	var license_verifier_script = preload("res://src/scripts/Services/LicenseVerifier.gd")
	if license_verifier_script.is_activated():
		if license_verifier.get_node("CanvasLayer").visible:
			license_verifier.get_node("CanvasLayer").hide()
		if not main_container.visible or main_container.modulate.a < 1.0:
			show_main_menu()
# === NAVIGATION FUNCTIONS ===

func _on_start_prelim_lesson_pressed():
	"""Navigate to Prelim Lesson with enhanced transition"""
	smooth_transition("res://src/scenes/Lesson/Prelim/Prelim_1.1.tscn", "📖 Loading Prelim Lesson...")
	
func _on_start_prelim_exam_button_pressed():
	"""Navigate to Prelim Exam with enhanced transition"""
	smooth_transition("res://src/scenes/Quiz/Prelim/Prelim_Quiz_1.1.tscn", "📋 Loading Prelim Exam...")
	
func _on_start_midterm_button_pressed():
	"""Navigate to Midterm Lesson with enhanced transition"""
	smooth_transition("res://src/scenes/Lesson/Midterm/Midterm_1.1.tscn", "🔬 Loading Midterm Lesson...")

func _on_button_4_pressed():
	"""Navigate to Practice Quiz with enhanced transition"""
	smooth_transition("res://src/scenes/Quiz/Prelim/Prelim_Quiz_1.1.tscn", "🎯 Loading Practice Quiz...")
	
func _on_quit_button_pressed() -> void:
	"""Enhanced quit sequence with confirmation"""
	animate_exit()
	await get_tree().create_timer(0.8).timeout
	get_tree().quit()

# === TRANSITION ANIMATIONS ===

func smooth_transition(scene_path: String, loading_text: String = "Loading..."):
	"""Enhanced scene transition with loading feedback"""
	if is_animating:
		return
	
	is_animating = true
	
	# Update status to show loading
	status_label.text = "🔄 " + loading_text
	
	if transition_tween:
		transition_tween.kill()
	
	transition_tween = create_tween()
	transition_tween.set_parallel(true)
	
	# Fade out and scale down main container
	transition_tween.tween_property(main_container, "modulate:a", 0.0, 0.5)
	transition_tween.tween_property(main_container, "scale", Vector2(0.9, 0.9), 0.5).set_trans(Tween.TRANS_BACK)
	
	# Slide panels out
	transition_tween.tween_property(left_panel, "position:x", -200, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	transition_tween.tween_property(right_panel, "position:x", 200, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	await transition_tween.finished
	get_tree().change_scene_to_file(scene_path)

func animate_exit():
	"""Enhanced exit animation sequence"""
	if is_animating:
		return
		
	is_animating = true
	status_label.text = "👋 Goodbye! Closing application..."
	
	if transition_tween:
		transition_tween.kill()
	
	transition_tween = create_tween()
	transition_tween.set_parallel(true)
	
	# Dramatic exit sequence
	transition_tween.tween_property(main_container, "modulate:a", 0.0, 0.8)
	transition_tween.tween_property(main_container, "scale", Vector2(0.7, 0.7), 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	transition_tween.tween_property(main_container, "rotation", deg_to_rad(-5), 0.8).set_trans(Tween.TRANS_SINE)
	
	# Slide panels away
	transition_tween.tween_property(left_panel, "position:x", -400, 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	transition_tween.tween_property(right_panel, "position:x", 400, 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
