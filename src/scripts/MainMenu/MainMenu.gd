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
@onready var resume_dialog: Control = $DialogCanvasLayer/ResumeProgressDialog

# Animation tweens
var entrance_tween: Tween
var transition_tween: Tween
var button_tweens: Dictionary = {}  # Store individual tweens for each button

# Animation states
var is_animating: bool = false
var buttons_array: Array[Button] = []
var resume_dialog_open: bool = false  # Prevent multiple dialog openings

func _ready() -> void:
	ApplicationManager.resume()
	setup_ui()
	
	# Connect license validation signal
	if not license_verifier.license_validated.is_connected(_on_license_validated):
		license_verifier.license_validated.connect(_on_license_validated)
	
	# Check license status and show appropriate UI
	check_license_status()

func check_license_status():
	"""Check license activation and show appropriate screen"""
	var license_verifier_script = preload("res://src/scripts/Services/LicenseVerifier.gd")
	if license_verifier_script.is_activated():
		# License is valid - hide verifier and show main menu
		license_verifier.get_node("CanvasLayer").hide()
		show_main_menu()
	else:
		# No valid license - hide main menu and show license verifier
		hide_main_menu()
		license_verifier.get_node("CanvasLayer").show()
		print("No valid license found - showing license verifier")

func _on_license_validated():
	"""Handle successful license validation"""
	print("License validated successfully - showing main menu")
	license_verifier.get_node("CanvasLayer").hide()
	show_main_menu()

func setup_ui():
	"""Initialize UI components and collect button references"""
	collect_buttons()
	setup_button_connections()
	setup_initial_state()  # Now safe - keeps UI visible
	update_status_display()

func setup_button_connections():
	"""Connect hover effects and interactions for all buttons"""
	for button in buttons_array:
		if button.mouse_entered.is_connected(_on_button_hover):
			button.mouse_entered.disconnect(_on_button_hover)
		if button.mouse_exited.is_connected(_on_button_unhover):
			button.mouse_exited.disconnect(_on_button_unhover)
			
		button.mouse_entered.connect(_on_button_hover.bind(button))
		button.mouse_exited.connect(_on_button_unhover.bind(button))

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
	
	print("📋 Collected ", buttons_array.size(), " buttons for animations")

func setup_initial_state():
	"""Set initial visual state - keep UI visible by default"""
	# Ensure main container is properly positioned and visible
	main_container.modulate.a = 1.0
	main_container.visible = true
	main_container.scale = Vector2(1.0, 1.0)
	main_container.rotation = 0.0
	
	# Reset panel positions to center (no offsets)
	left_panel.position.x = 0
	right_panel.position.x = 0
	
	# Set buttons to normal state and clean up any existing tweens
	reset_all_buttons()
	
	print("Main menu UI setup complete - all elements reset to default state")

func reset_all_buttons():
	"""Reset all buttons to their default state"""
	# Clear any existing button tweens
	for tween in button_tweens.values():
		if tween.is_valid():
			tween.kill()
	button_tweens.clear()
	
	# Reset button states to normal
	for button in buttons_array:
		button.scale = Vector2(1.0, 1.0)
		button.modulate = Color(1.0, 1.0, 1.0, 1.0)  # Full visibility
		button.rotation = 0.0
		button.disabled = false  # Ensure buttons are always enabled
		button.visible = true    # Ensure buttons are visible

func update_status_display():
	"""Update status information"""
	var current_time = Time.get_datetime_string_from_system()
	status_label.text = "🟢 System Ready | " + current_time.split("T")[0]

func show_main_menu():
	"""Show main menu with entrance animations"""
	main_container.modulate.a = 1.0
	main_container.visible = true
	
	# Reset any transform changes to ensure proper layout
	left_panel.position.x = 0
	right_panel.position.x = 0
	main_container.scale = Vector2(1.0, 1.0)
	main_container.rotation = 0.0
	
	# Make sure all buttons are visible and properly reset
	reset_all_buttons()
	
	print("Main menu shown - layout restored")

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
	
	# Complete animation callback with proper interval
	entrance_tween.tween_interval(1.5)
	entrance_tween.tween_callback(func(): is_animating = false)

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
	pass
	
# === NAVIGATION FUNCTIONS ===

func _on_start_prelim_lesson_pressed():
	"""Navigate to Prelim Lesson with resume option"""
	print("Prelim lesson button clicked!")
	
	# TEMPORARY DEBUG: Test progress system
	print("=== DEBUG PROGRESS TEST ===")
	if ProgressManager:
		print("ProgressManager exists")
		print("Current progress data: ", ProgressManager.progress_data)
		var has_progress = ProgressManager.has_progress()
		print("has_progress(): ", has_progress)
		if has_progress:
			var resume_info = ProgressManager.get_resume_info()
			print("get_resume_info(): ", resume_info)
	else:
		print("ProgressManager is null!")
	print("=== END DEBUG ===")
	
	show_lesson_with_resume("prelim")
	
func _on_start_prelim_exam_button_pressed():
	"""Navigate to Prelim Exam with enhanced transition"""
	smooth_transition("res://src/scenes/Quiz/Prelim/Prelim_Quiz_1.1.tscn", "📋 Loading Prelim Exam...")

func _on_start_midterm_exam_button_pressed():
	"""Navigate to Midterm Exam (Quiz 1.1) with enhanced transition"""
	print("Midterm Exam button clicked!")
	smooth_transition("res://src/scenes/Quiz/Midterm/Midterm_Quiz_1.1.tscn", "📋 Loading Midterm Exam...")
	
func _on_start_midterm_button_pressed():
	"""Navigate to Midterm Lesson with resume option"""
	print("Midterm lesson button clicked!")
	show_lesson_with_resume("midterm")

func _on_button_4_pressed():
	"""Navigate to Practice Quiz with enhanced transition"""
	smooth_transition("res://src/scenes/Quiz/Prelim/Prelim_Quiz_1.1.tscn", "🎯 Loading Practice Quiz...")

func show_lesson_with_resume(lesson_type: String):
	"""Show resume dialog or navigate directly to lessons"""
	print("=== show_lesson_with_resume called ===")
	print("Lesson type: ", lesson_type)
	print("Resume dialog open: ", resume_dialog_open)
	print("Has progress: ", ProgressManager.has_progress())
	
	# Get lesson-type specific resume info instead of global most recent
	var resume_info = ProgressManager.get_resume_info_for_lesson_type(lesson_type)
	print("Resume info for %s: " % lesson_type, resume_info)
	
	if not resume_info.is_empty() and resume_info.lesson_number > 1:
		print("Showing resume dialog for %s lesson %d" % [lesson_type, resume_info.lesson_number])
		resume_dialog_open = true
		# Show resume dialog
		resume_dialog.show_resume_dialog(lesson_type)
		return
	else:
		print("No relevant progress for %s or lesson <= 1" % lesson_type)
	
	# No relevant progress, start fresh
	print("Starting fresh from lesson 1")
	_on_start_fresh_selected(lesson_type)

# === RESUME DIALOG HANDLERS ===

func _on_resume_selected(lesson_type: String, lesson_number: int):
	"""Handle resume from specific lesson"""
	print("Resume selected: ", lesson_type, " lesson ", lesson_number)
	resume_dialog_open = false
	var scene_path = ProgressManager.get_lesson_scene_path(lesson_type, lesson_number)
	var display_name = "%s Lesson %d" % [lesson_type.capitalize(), lesson_number]
	smooth_transition(scene_path, "📖 Resuming %s..." % display_name)

func _on_start_fresh_selected(lesson_type: String):
	"""Handle start fresh from lesson 1"""
	print("Start fresh selected: ", lesson_type)
	resume_dialog_open = false
	# Clear progress for this lesson type and start from 1
	ProgressManager.reset_to_lesson(lesson_type, 1)
	
	var scene_path = ProgressManager.get_lesson_scene_path(lesson_type, 1)
	var display_name = "%s Lesson" % lesson_type.capitalize()
	
	# Check if scene file exists
	if not FileAccess.file_exists(scene_path):
		# Fallback to a known working scene
		if lesson_type == "prelim":
			scene_path = "res://src/scenes/Lesson/Prelim/Prelim_1.1.tscn"
		else:
			scene_path = "res://src/scenes/Lesson/Midterm/Midterm_1.1.tscn"
	
	smooth_transition(scene_path, "🔄 Starting Fresh %s..." % display_name)

func _on_resume_dialog_closed():
	"""Handle resume dialog being closed without selection"""
	print("Resume dialog closed")
	resume_dialog_open = false
	# Dialog was cancelled, do nothing
	pass
	
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
