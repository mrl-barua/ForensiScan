extends Node2D

# Midterm Quiz 1.2 - Results and Continuation Screen
# Professional completion screen with navigation options

# UI Node references
@onready var header_label: Label = $Header
@onready var sub_header_label: Label = $SubHeader
@onready var main_panel: Panel = $MainPanel
@onready var completion_message: Label = $MainPanel/CompletionMessage
@onready var review_button: Button = $ActionButtons/ReviewButton
@onready var continue_button: Button = $ActionButtons/ContinueButton
@onready var main_menu_button: Button = $ActionButtons/MainMenuButton
@onready var progress_label: Label = $ProgressIndicator/ProgressLabel

# Animation and state variables
var entrance_tween: Tween
var button_tweens: Dictionary = {}
var has_animated: bool = false

func _ready():
	print("🎉 Midterm Quiz 1.2 Results Screen initialized")
	setup_simplified_content()
	setup_entrance_animation()
	connect_button_signals()
	setup_button_hover_effects()

func setup_simplified_content():
	"""Set up clean, minimal content"""
	# Ensure text content matches the simplified scene
	if completion_message:
		completion_message.text = """Excellent work! You've completed the enumeration quiz.

📋 What's Next:
Using the fingerprint image from this activity, complete the advanced classification analysis on paper:

• Secondary Classification
• Sub-Secondary Classification  

📝 Submit your written work to the instructor for evaluation.

🎯 This practical exercise applies your forensic analysis skills!"""

func setup_entrance_animation():
	"""Create smooth entrance animation for all elements"""
	# Initially hide elements for animation
	header_label.modulate.a = 0.0
	sub_header_label.modulate.a = 0.0
	main_panel.modulate.a = 0.0
	progress_label.modulate.a = 0.0
	
	# Hide buttons
	for button in [$ActionButtons/ReviewButton, $ActionButtons/ContinueButton, $ActionButtons/MainMenuButton]:
		button.modulate.a = 0.0
		button.scale = Vector2(0.8, 0.8)
	
	# Start entrance sequence
	await get_tree().create_timer(0.3).timeout
	animate_entrance()

func animate_entrance():
	"""Animate elements appearing in sequence"""
	if has_animated:
		return
	
	has_animated = true
	entrance_tween = create_tween()
	entrance_tween.set_parallel(true)
	
	# Header animation
	entrance_tween.tween_property(header_label, "modulate:a", 1.0, 0.6).set_delay(0.0)
	entrance_tween.tween_property(header_label, "position:y", header_label.position.y + 20, 0.6).set_delay(0.0).set_trans(Tween.TRANS_BACK)
	
	# Sub-header animation
	entrance_tween.tween_property(sub_header_label, "modulate:a", 1.0, 0.6).set_delay(0.3)
	
	# Main panel animation
	entrance_tween.tween_property(main_panel, "modulate:a", 1.0, 0.8).set_delay(0.6)
	entrance_tween.tween_property(main_panel, "scale", Vector2(1.0, 1.0), 0.8).set_delay(0.6).set_trans(Tween.TRANS_BACK)
	
	# Button animations (staggered)
	var buttons = [$ActionButtons/ReviewButton, $ActionButtons/ContinueButton, $ActionButtons/MainMenuButton]
	for i in range(buttons.size()):
		var button = buttons[i]
		var delay = 1.2 + (i * 0.2)
		entrance_tween.tween_property(button, "modulate:a", 1.0, 0.4).set_delay(delay)
		entrance_tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.4).set_delay(delay).set_trans(Tween.TRANS_BACK)
	
	# Progress indicator
	entrance_tween.tween_property(progress_label, "modulate:a", 1.0, 0.5).set_delay(2.0)
	
	# Set initial panel scale for animation
	main_panel.scale = Vector2(0.9, 0.9)

func connect_button_signals():
	"""Connect button press signals"""
	if review_button and not review_button.pressed.is_connected(_on_review_button_pressed):
		review_button.pressed.connect(_on_review_button_pressed)
	
	if continue_button and not continue_button.pressed.is_connected(_on_continue_button_pressed):
		continue_button.pressed.connect(_on_continue_button_pressed)
	
	if main_menu_button and not main_menu_button.pressed.is_connected(_on_main_menu_button_pressed):
		main_menu_button.pressed.connect(_on_main_menu_button_pressed)

func setup_button_hover_effects():
	"""Setup hover effects for all buttons"""
	var buttons = [review_button, continue_button, main_menu_button]
	
	for button in buttons:
		if not button:
			continue
		
		# Connect hover signals
		if not button.mouse_entered.is_connected(_on_button_hover_entered):
			button.mouse_entered.connect(_on_button_hover_entered.bind(button))
		if not button.mouse_exited.is_connected(_on_button_hover_exited):
			button.mouse_exited.connect(_on_button_hover_exited.bind(button))

func _on_button_hover_entered(button: Button):
	"""Handle button hover enter with animation"""
	var button_id = button.get_instance_id()
	
	# Kill existing tween for this button
	if button_tweens.has(button_id):
		button_tweens[button_id].kill()
	
	# Create new hover tween
	button_tweens[button_id] = create_tween()
	var tween = button_tweens[button_id]
	tween.set_parallel(true)
	
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property(button, "modulate", Color(1.1, 1.1, 1.2, 1.0), 0.2)

func _on_button_hover_exited(button: Button):
	"""Handle button hover exit with animation"""
	var button_id = button.get_instance_id()
	
	# Kill existing tween for this button
	if button_tweens.has(button_id):
		button_tweens[button_id].kill()
	
	# Create new exit tween
	button_tweens[button_id] = create_tween()
	var tween = button_tweens[button_id]
	tween.set_parallel(true)
	
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property(button, "modulate", Color.WHITE, 0.2)

func _on_review_button_pressed():
	"""Handle review answers button press"""
	print("📊 Review button pressed - returning to previous quiz")
	
	# Animate button press
	animate_button_press(review_button)
	
	# Wait for animation then navigate
	await get_tree().create_timer(0.3).timeout
	
	# Return to previous quiz scene to review answers
	get_tree().change_scene_to_file("res://src/scenes/Quiz/Midterm/Midterm_Quiz_1.1.tscn")

func _on_continue_button_pressed():
	"""Handle continue to next section button press"""
	print("🎯 Continue button pressed - proceeding to next activity")
	
	# Animate button press
	animate_button_press(continue_button)
	
	# Wait for animation then navigate
	await get_tree().create_timer(0.3).timeout
	
	# Check if next scene exists, otherwise go to main menu
	var next_scene = "res://src/scenes/Quiz/Midterm/Midterm_Quiz_2.1.tscn"
	if FileAccess.file_exists(next_scene):
		get_tree().change_scene_to_file(next_scene)
	else:
		print("📝 Next quiz section not yet available - returning to main menu")
		get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn")

func _on_main_menu_button_pressed():
	"""Handle main menu button press"""
	print("🏠 Main menu button pressed - returning to main menu")
	
	# Animate button press
	animate_button_press(main_menu_button)
	
	# Wait for animation then navigate
	await get_tree().create_timer(0.3).timeout
	
	# Return to main menu
	get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn")

func animate_button_press(button: Button):
	"""Animate button press effect"""
	var press_tween = create_tween()
	press_tween.set_parallel(true)
	
	# Scale down then back up
	press_tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.1)
	press_tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2).set_delay(0.1).set_trans(Tween.TRANS_BACK)
	
	# Color flash
	press_tween.tween_property(button, "modulate", Color(1.2, 1.2, 1.0, 1.0), 0.1)
	press_tween.tween_property(button, "modulate", Color.WHITE, 0.2).set_delay(0.1)

func update_progress_display(score: int = -1, total_questions: int = 10):
	"""Update progress display with quiz results"""
	if progress_label:
		var progress_text = "📈 Progress: Midterm Part 1 Complete"
		
		if score >= 0:
			var percentage = (score / float(total_questions)) * 100
			progress_text += " | Score: %d/%d (%.0f%%)" % [score, total_questions, percentage]
		
		progress_text += " | Next: Advanced Classification Analysis | Overall: 50% Complete"
		progress_label.text = progress_text

# Function to receive score data from previous scene (if needed)
func set_quiz_results(score: int, total_questions: int):
	"""Set quiz results from previous scene"""
	print("📊 Quiz results received: %d/%d" % [score, total_questions])
	update_progress_display(score, total_questions)
	
	# Update completion message with score
	if completion_message:
		var current_text = completion_message.text
		var score_percentage = (score / float(total_questions)) * 100
		var grade = get_letter_grade(score_percentage)
		
		# Add score information to the message
		var score_info = "\n\n🏆 YOUR RESULTS:\n"
		score_info += "• Final Score: %d out of %d questions correct\n" % [score, total_questions]
		score_info += "• Percentage: %.0f%%\n" % score_percentage
		score_info += "• Letter Grade: %s\n" % grade
		score_info += "• Performance: %s" % get_performance_message(score_percentage)
		
		completion_message.text = current_text + score_info

func get_letter_grade(percentage: float) -> String:
	"""Convert percentage to letter grade"""
	if percentage >= 97: return "A+"
	elif percentage >= 93: return "A"
	elif percentage >= 90: return "A-"
	elif percentage >= 87: return "B+"
	elif percentage >= 83: return "B"
	elif percentage >= 80: return "B-"
	elif percentage >= 77: return "C+"
	elif percentage >= 73: return "C"
	elif percentage >= 70: return "C-"
	elif percentage >= 67: return "D+"
	elif percentage >= 65: return "D"
	else: return "F"

func get_performance_message(percentage: float) -> String:
	"""Get encouraging performance message"""
	if percentage >= 90:
		return "Excellent! Outstanding forensic analysis skills!"
	elif percentage >= 80:
		return "Very Good! Strong understanding demonstrated!"
	elif percentage >= 70:
		return "Good! Continue practicing your skills!"
	elif percentage >= 60:
		return "Fair! Review the material for improvement!"
	else:
		return "Keep studying! Practice makes perfect!"
