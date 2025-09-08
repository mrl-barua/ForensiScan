extends Node2D

# Midterm Quiz Result - Displays detailed results from enumeration quiz
# Shows scores, grades, and performance analysis

# UI Node references
@onready var header_label: Label = $Header
@onready var results_panel: Panel = $ResultsPanel
@onready var quiz_title: Label = $ResultsPanel/QuizTitle
@onready var score_panel: Panel = $ResultsPanel/ScoreDisplay/ScorePanel
@onready var score_value: Label = $ResultsPanel/ScoreDisplay/ScorePanel/ScoreInfo/ScoreValue
@onready var score_percentage: Label = $ResultsPanel/ScoreDisplay/ScorePanel/ScoreInfo/ScorePercentage
@onready var letter_grade: Label = $ResultsPanel/ScoreDisplay/ScorePanel/ScoreInfo/LetterGrade
@onready var performance_message: Label = $ResultsPanel/ScoreDisplay/PerformanceMessage
@onready var correct_answers: Label = $ResultsPanel/ScoreDisplay/DetailedResults/CorrectAnswers
@onready var incorrect_answers: Label = $ResultsPanel/ScoreDisplay/DetailedResults/IncorrectAnswers

@onready var retry_button: Button = $ActionButtons/RetryButton
@onready var continue_button: Button = $ActionButtons/ContinueButton
@onready var main_menu_button: Button = $ActionButtons/MainMenuButton

# Quiz data
var quiz_score: int = 0
var total_questions: int = 10
var correct_count: int = 0
var incorrect_count: int = 0
var percentage: float = 0.0
var grade: String = ""

# Animation variables
var entrance_tween: Tween
var button_tweens: Dictionary = {}

func _ready():
	print("📊 Midterm Quiz Results Screen initialized")
	
	# Try to get score data from QuizManager autoload if it exists
	load_quiz_data()
	setup_results_display()
	setup_entrance_animation()
	connect_button_signals()

func load_quiz_data():
	"""Load quiz data from QuizManager autoload"""
	# Get latest quiz results from QuizManager
	var quiz_results = QuizManager.get_latest_score()
	
	if quiz_results.has("score"):
		quiz_score = quiz_results.get("score", 0)
		total_questions = quiz_results.get("total_questions", 10)
		print("📊 Quiz data loaded from QuizManager:")
		print("  Score: ", quiz_score)
		print("  Total Questions: ", total_questions)
	else:
		# Fallback - no data found, use default values
		quiz_score = 0
		total_questions = 10
		print("⚠️ No quiz data found in QuizManager, using defaults")
	
	# Calculate derived values
	correct_count = quiz_score / 10  # Each question worth 10 points
	incorrect_count = total_questions - correct_count
	percentage = (quiz_score / 100.0) * 100
	grade = get_letter_grade(percentage)
	
	print("📋 Final Quiz Results:")
	print("  Score: ", quiz_score, "/100")
	print("  Correct: ", correct_count, "/", total_questions)
	print("  Percentage: ", percentage, "%")
	print("  Grade: ", grade)

func setup_results_display():
	"""Setup and populate all result display elements"""
	# Update score displays
	if score_value:
		score_value.text = "%d/100" % quiz_score
	
	if score_percentage:
		score_percentage.text = "%.0f%%" % percentage
	
	if letter_grade:
		letter_grade.text = "Grade: %s" % grade
	
	# Update detailed results
	if correct_answers:
		correct_answers.text = "✅ Correct Answers: %d/%d" % [correct_count, total_questions]
	
	if incorrect_answers:
		incorrect_answers.text = "❌ Incorrect Answers: %d/%d" % [incorrect_count, total_questions]
	
	# Update performance message
	if performance_message:
		performance_message.text = get_performance_message(percentage)
	
	# Update score panel color based on performance
	update_score_panel_style()

func update_score_panel_style():
	"""Update score panel color based on performance"""
	if not score_panel:
		return
	
	var style = score_panel.get_theme_stylebox("panel").duplicate()
	
	if percentage >= 90:
		# Excellent - Green
		style.bg_color = Color(0.2, 0.7, 0.3, 0.9)
		style.border_color = Color(0.3, 0.9, 0.4, 1)
	elif percentage >= 80:
		# Very Good - Blue
		style.bg_color = Color(0.2, 0.5, 0.7, 0.9)
		style.border_color = Color(0.3, 0.7, 0.9, 1)
	elif percentage >= 70:
		# Good - Purple
		style.bg_color = Color(0.5, 0.3, 0.7, 0.9)
		style.border_color = Color(0.7, 0.4, 0.9, 1)
	elif percentage >= 60:
		# Fair - Orange
		style.bg_color = Color(0.7, 0.5, 0.2, 0.9)
		style.border_color = Color(0.9, 0.7, 0.3, 1)
	else:
		# Needs Improvement - Red
		style.bg_color = Color(0.7, 0.3, 0.2, 0.9)
		style.border_color = Color(0.9, 0.4, 0.3, 1)
	
	score_panel.add_theme_stylebox_override("panel", style)

func setup_entrance_animation():
	"""Create smooth entrance animation"""
	# Initially hide elements
	header_label.modulate.a = 0.0
	results_panel.modulate.a = 0.0
	results_panel.scale = Vector2(0.8, 0.8)
	
	for button in [retry_button, continue_button, main_menu_button]:
		if button:
			button.modulate.a = 0.0
			button.scale = Vector2(0.8, 0.8)
	
	# Start animation
	await get_tree().create_timer(0.2).timeout
	animate_entrance()

func animate_entrance():
	"""Animate elements appearing"""
	entrance_tween = create_tween()
	entrance_tween.set_parallel(true)
	
	# Header animation
	entrance_tween.tween_property(header_label, "modulate:a", 1.0, 0.6)
	
	# Results panel animation
	entrance_tween.tween_property(results_panel, "modulate:a", 1.0, 0.8).set_delay(0.3)
	entrance_tween.tween_property(results_panel, "scale", Vector2(1.0, 1.0), 0.8).set_delay(0.3).set_trans(Tween.TRANS_BACK)
	
	# Button animations (staggered)
	var buttons = [retry_button, continue_button, main_menu_button]
	for i in range(buttons.size()):
		var button = buttons[i]
		if button:
			var delay = 1.0 + (i * 0.15)
			entrance_tween.tween_property(button, "modulate:a", 1.0, 0.4).set_delay(delay)
			entrance_tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.4).set_delay(delay).set_trans(Tween.TRANS_BACK)

func connect_button_signals():
	"""Connect button press signals"""
	if retry_button and not retry_button.pressed.is_connected(_on_retry_button_pressed):
		retry_button.pressed.connect(_on_retry_button_pressed)
	
	if continue_button and not continue_button.pressed.is_connected(_on_continue_button_pressed):
		continue_button.pressed.connect(_on_continue_button_pressed)
	
	if main_menu_button and not main_menu_button.pressed.is_connected(_on_main_menu_button_pressed):
		main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	
	# Setup hover effects
	for button in [retry_button, continue_button, main_menu_button]:
		if button:
			if not button.mouse_entered.is_connected(_on_button_hover_entered):
				button.mouse_entered.connect(_on_button_hover_entered.bind(button))
			if not button.mouse_exited.is_connected(_on_button_hover_exited):
				button.mouse_exited.connect(_on_button_hover_exited.bind(button))

func _on_button_hover_entered(button: Button):
	"""Handle button hover"""
	var button_id = button.get_instance_id()
	if button_tweens.has(button_id):
		button_tweens[button_id].kill()
	
	button_tweens[button_id] = create_tween()
	var tween = button_tweens[button_id]
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.2)
	tween.tween_property(button, "modulate", Color(1.1, 1.1, 1.2, 1.0), 0.2)

func _on_button_hover_exited(button: Button):
	"""Handle button hover exit"""
	var button_id = button.get_instance_id()
	if button_tweens.has(button_id):
		button_tweens[button_id].kill()
	
	button_tweens[button_id] = create_tween()
	var tween = button_tweens[button_id]
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)
	tween.tween_property(button, "modulate", Color.WHITE, 0.2)

func _on_retry_button_pressed():
	"""Handle retry quiz button"""
	print("🔄 Retry button pressed - returning to quiz")
	animate_button_press(retry_button)
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://src/scenes/Quiz/Midterm/Midterm_Quiz_1.1.tscn")

func _on_continue_button_pressed():
	"""Handle continue button"""
	print("➡️ Continue button pressed - proceeding")
	animate_button_press(continue_button)
	await get_tree().create_timer(0.3).timeout
	
	# Try to go to next quiz section or return to completion screen
	var next_scene = "res://src/scenes/Quiz/Midterm/Midterm_Quiz_2.1.tscn"
	if FileAccess.file_exists(next_scene):
		get_tree().change_scene_to_file(next_scene)
	else:
		# Return to completion screen
		get_tree().change_scene_to_file("res://src/scenes/Quiz/Midterm/Midterm_Quiz_1.2.tscn")

func _on_main_menu_button_pressed():
	"""Handle main menu button"""
	print("🏠 Main menu button pressed")
	animate_button_press(main_menu_button)
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn")

func animate_button_press(button: Button):
	"""Animate button press"""
	var press_tween = create_tween()
	press_tween.set_parallel(true)
	press_tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.1)
	press_tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2).set_delay(0.1).set_trans(Tween.TRANS_BACK)
	press_tween.tween_property(button, "modulate", Color(1.2, 1.2, 1.0, 1.0), 0.1)
	press_tween.tween_property(button, "modulate", Color.WHITE, 0.2).set_delay(0.1)

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
	"""Get performance message based on score"""
	if percentage >= 90:
		return "Excellent! Outstanding understanding of forensic fingerprint analysis!"
	elif percentage >= 80:
		return "Very Good! Strong grasp of forensic principles demonstrated."
	elif percentage >= 70:
		return "Good! Solid foundation with room for improvement in some areas."
	elif percentage >= 60:
		return "Fair! Continue studying to strengthen your forensic knowledge."
	else:
		return "Keep practicing! Review the material and try again to improve your skills."

# Function to set quiz results from previous scene
func set_quiz_results(score: int, total: int, user_answers: Array = [], correct_answers: Array = []):
	"""Set quiz results data"""
	quiz_score = score
	total_questions = total
	correct_count = score / 10
	incorrect_count = total_questions - correct_count
	percentage = (score / 100.0) * 100
	grade = get_letter_grade(percentage)
	
	print("📊 Results set: Score=%d, Total=%d, Grade=%s" % [score, total, grade])
	
	# Update display if nodes are ready
	if is_node_ready():
		setup_results_display()
