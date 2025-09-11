extends Node2D

# Semining Quiz - Enumeration Type
# Professional quiz system with scoring and validation

# UI Node references
@onready var question_1: LineEdit = $Question_1
@onready var question_2: LineEdit = $Question_2
@onready var question_3: LineEdit = $Question_3
@onready var question_4: LineEdit = $Question_4
@onready var question_5: LineEdit = $Question_5
@onready var question_6: LineEdit = $Question_6
@onready var question_7: LineEdit = $Question_7
@onready var question_8: LineEdit = $Question_8
@onready var submit_button: Button = $OptionA
@onready var header_label: Label = $Header
@onready var instruction_label: Label = $Instruction
@onready var question_labels: Control = $QuestionLabels

# Quiz data and state
var quiz_data: Array = []
var question_inputs: Array[LineEdit] = []
var user_answers: Array[String] = []
var correct_answers: Array[String] = []
var is_submitted: bool = false
var score: int = 0

# Enhanced UI/UX variables
var input_tweens: Dictionary = {}
var submission_tween: Tween
var success_color: Color = Color(0.2, 0.8, 0.3, 1.0)
var error_color: Color = Color(0.9, 0.3, 0.2, 1.0)
var neutral_color: Color = Color(0.15, 0.15, 0.25, 0.9)

func _ready():
	print("🎯 Semining Quiz 1.2 initialized")
	setup_quiz()
	setup_ui_enhancements()
	load_quiz_data()
	connect_signals()

func setup_quiz():
	"""Initialize quiz components and collect references"""
	# Collect all question input references
	question_inputs = [
		question_1, question_2, question_3, question_4, question_5,
		question_6, question_7, question_8
	]
	
	# Validate all inputs exist
	for i in range(question_inputs.size()):
		if not question_inputs[i]:
			print("❌ Warning: Question input ", i + 1, " not found!")
		else:
			question_inputs[i].placeholder_text = "Enter your answer here..."
	
	print("✅ Found ", question_inputs.size(), " question inputs")

func setup_ui_enhancements():
	"""Setup enhanced UI elements and styling"""
	# Update header with better text
	if header_label:
		header_label.text = "SEMINING EXAMINATION - ACTIVITY NO. 2"
	
	# Update instruction text
	if instruction_label:
		instruction_label.text = """Instructions: Answer the following questions by typing your answers in the text fields below.

📝 This is an enumeration quiz - provide specific, accurate answers
⏱️  Take your time to think carefully about each answer
✅ Click Submit when you're ready to check your answers
🎯 Each question is worth 10 points (Total: 100 points)"""
	
	# Update submit button
	if submit_button:
		submit_button.text = "Submit Quiz"
		submit_button.disabled = false

func load_quiz_data():
	"""Load quiz questions and answers from JSON file"""
	var file_path = "res://assets/json/question.json"
	
	if not FileAccess.file_exists(file_path):
		print("❌ Question file not found: ", file_path)
		return
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("❌ Failed to open question file")
		return
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		print("❌ Failed to parse JSON: ", json.get_error_message())
		return
	
	var data = json.data
	if not data.has("Semining"):
		print("❌ No Semining section found in question data")
		return
	
	quiz_data = data["Semining"]
	
	# Extract correct answers
	correct_answers.clear()
	for question in quiz_data:
		correct_answers.append(question.get("answer", ""))
	
	print("✅ Loaded ", quiz_data.size(), " questions")
	print("📋 Correct answers loaded: ", correct_answers.size())

func connect_signals():
	"""Connect UI signals for enhanced interaction"""
	# Connect submit button
	if submit_button and not submit_button.pressed.is_connected(_on_submit_pressed):
		submit_button.pressed.connect(_on_submit_pressed)
	
	# Connect input field signals for better UX
	for i in range(question_inputs.size()):
		var input = question_inputs[i]
		if input:
			# Connect focus signals for visual feedback
			if not input.focus_entered.is_connected(_on_input_focus_entered):
				input.focus_entered.connect(_on_input_focus_entered.bind(input))
			if not input.focus_exited.is_connected(_on_input_focus_exited):
				input.focus_exited.connect(_on_input_focus_exited.bind(input))
			
			# Connect text changed for real-time feedback
			if not input.text_changed.is_connected(_on_input_text_changed):
				input.text_changed.connect(_on_input_text_changed.bind(i))

func _on_input_focus_entered(input: LineEdit):
	"""Handle input field focus with smooth animation"""
	if is_submitted:
		return
	
	animate_input_focus(input, true)

func _on_input_focus_exited(input: LineEdit):
	"""Handle input field focus lost"""
	if is_submitted:
		return
	
	animate_input_focus(input, false)

func _on_input_text_changed(text: String, question_index: int):
	"""Handle real-time text changes for UX feedback"""
	if is_submitted:
		return
	
	var input = question_inputs[question_index]
	if input:
		# Add subtle feedback for non-empty inputs
		if text.strip_edges().length() > 0:
			input.modulate = Color(1.1, 1.1, 1.0, 1.0)  # Slight yellow tint
		else:
			input.modulate = Color.WHITE

func animate_input_focus(input: LineEdit, focused: bool):
	"""Animate input field focus state"""
	var input_id = input.get_instance_id()
	
	# Kill existing tween for this input
	if input_tweens.has(input_id):
		input_tweens[input_id].kill()
	
	# Create new tween
	input_tweens[input_id] = create_tween()
	var tween = input_tweens[input_id]
	tween.set_parallel(true)
	
	if focused:
		tween.tween_property(input, "scale", Vector2(1.02, 1.02), 0.2).set_trans(Tween.TRANS_BACK)
		tween.tween_property(input, "modulate", Color(1.1, 1.1, 1.2, 1.0), 0.2)
	else:
		tween.tween_property(input, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK)
		tween.tween_property(input, "modulate", Color.WHITE, 0.2)

func _on_submit_pressed():
	"""Handle quiz submission with validation and scoring"""
	if is_submitted:
		# If already submitted, go to next scene or show results again
		show_final_results()
		return
	
	print("📝 Processing quiz submission...")
	
	# Disable submit button to prevent double submission
	submit_button.disabled = true
	
	# Collect user answers
	collect_user_answers()
	
	# Validate and score
	calculate_score()
	
	# Show results with animations
	show_quiz_results()
	
	# Mark as submitted
	is_submitted = true
	
	# Update submit button
	submit_button.text = "View Results"
	submit_button.disabled = false

func collect_user_answers():
	"""Collect answers from all input fields"""
	user_answers.clear()
	
	for i in range(question_inputs.size()):
		var input = question_inputs[i]
		if input:
			var answer = input.text.strip_edges()
			user_answers.append(answer)
		else:
			user_answers.append("")
	
	print("📋 Collected ", user_answers.size(), " user answers")

func calculate_score():
	"""Calculate quiz score with flexible answer matching"""
	score = 0
	
	for i in range(min(user_answers.size(), correct_answers.size())):
		var user_answer = user_answers[i].to_lower().strip_edges()
		var correct_answer = correct_answers[i].to_lower().strip_edges()
		
		# Flexible matching - exact match or close match
		if is_answer_correct(user_answer, correct_answer):
			score += 10  # Each question worth 10 points
			print("✅ Question ", i + 1, " correct: '", user_answers[i], "'")
		else:
			print("❌ Question ", i + 1, " incorrect. Expected: '", correct_answers[i], "', Got: '", user_answers[i], "'")
	
	var percentage = (score / 100.0) * 100
	print("🎯 Final Score: ", score, "/100 (", percentage, "%)")

func is_answer_correct(user_answer: String, correct_answer: String) -> bool:
	"""Enhanced answer validation with flexible matching"""
	# Direct match
	if user_answer == correct_answer:
		return true
	
	# Remove common variations and check again
	var normalized_user = normalize_answer(user_answer)
	var normalized_correct = normalize_answer(correct_answer)
	
	if normalized_user == normalized_correct:
		return true
	
	# Check if user answer contains the correct answer (for partial credit)
	if normalized_correct.length() > 3 and normalized_user.contains(normalized_correct):
		return true
	
	return false

func normalize_answer(answer: String) -> String:
	"""Normalize answer for better matching"""
	return answer.to_lower().strip_edges().replace(" ", "").replace("-", "").replace("_", "")

func show_quiz_results():
	"""Display quiz results with visual feedback"""
	print("🎭 Displaying quiz results with animations...")
	
	# Animate each input field based on correctness
	for i in range(min(question_inputs.size(), correct_answers.size())):
		var input = question_inputs[i]
		if not input:
			continue
		
		var user_answer = user_answers[i].to_lower().strip_edges()
		var correct_answer = correct_answers[i].to_lower().strip_edges()
		var is_correct = is_answer_correct(user_answer, correct_answer)
		
		# Disable input and show result
		input.editable = false
		
		# Color coding and animation
		animate_result_feedback(input, is_correct, i)
	
	# Show overall score
	await get_tree().create_timer(2.0).timeout
	show_score_summary()

func animate_result_feedback(input: LineEdit, is_correct: bool, question_index: int):
	"""Animate individual result feedback"""
	var delay = question_index * 0.1  # Stagger animations
	
	await get_tree().create_timer(delay).timeout
	
	var feedback_tween = create_tween()
	feedback_tween.set_parallel(true)
	
	# Get corresponding question label
	var label_node = question_labels.get_child(question_index) if question_labels else null
	
	if is_correct:
		# Success animation
		var success_style = input.get_theme_stylebox("normal").duplicate()
		success_style.bg_color = success_color
		success_style.border_color = Color(0.3, 1.0, 0.4, 0.9)
		
		feedback_tween.tween_property(input, "modulate", Color(0.8, 1.2, 0.8, 1.0), 0.3)
		feedback_tween.tween_property(input, "scale", Vector2(1.05, 1.05), 0.3).set_trans(Tween.TRANS_BACK)
		
		# Highlight question label in green
		if label_node:
			feedback_tween.tween_property(label_node, "modulate", success_color, 0.3)
		
		# Reset after animation
		feedback_tween.chain()
		feedback_tween.tween_property(input, "scale", Vector2(1.0, 1.0), 0.2)
	else:
		# Error animation
		var error_style = input.get_theme_stylebox("normal").duplicate()
		error_style.bg_color = error_color
		error_style.border_color = Color(1.0, 0.4, 0.4, 0.9)
		
		# Shake animation for incorrect answers
		var original_pos = input.position
		for j in range(3):
			feedback_tween.tween_property(input, "position", original_pos + Vector2(5, 0), 0.05)
			feedback_tween.tween_property(input, "position", original_pos + Vector2(-5, 0), 0.05)
		feedback_tween.tween_property(input, "position", original_pos, 0.05)
		
		feedback_tween.tween_property(input, "modulate", Color(1.2, 0.8, 0.8, 1.0), 0.3)
		
		# Highlight question label in red
		if label_node:
			feedback_tween.tween_property(label_node, "modulate", error_color, 0.3)

func show_score_summary():
	"""Display final score summary"""
	var percentage = (score / 100.0) * 100
	var grade = get_letter_grade(percentage)
	var performance = get_performance_message(percentage)
	
	print("🏆 Quiz Complete!")
	print("📊 Score: ", score, "/100 (", percentage, "%)")
	print("📝 Grade: ", grade)
	print("💬 ", performance)
	
	# Update header with results
	if header_label:
		header_label.text = "QUIZ COMPLETE - SCORE: %d/100 (%d%%) - GRADE: %s" % [score, percentage, grade]
		
		# Animate header color based on performance
		var header_tween = create_tween()
		if percentage >= 80:
			header_tween.tween_property(header_label, "modulate", success_color, 0.5)
		elif percentage >= 60:
			header_tween.tween_property(header_label, "modulate", Color(1.0, 0.8, 0.2, 1.0), 0.5)
		else:
			header_tween.tween_property(header_label, "modulate", error_color, 0.5)

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
		return "Excellent work! Outstanding understanding of fingerprint analysis!"
	elif percentage >= 80:
		return "Very good! Strong grasp of forensic concepts!"
	elif percentage >= 70:
		return "Good job! Continue studying to improve your forensic skills!"
	elif percentage >= 60:
		return "Fair performance. Review the material and practice more!"
	else:
		return "Keep studying! Forensic science requires dedication and practice!"

func show_final_results():
	"""Show detailed results or navigate to next section"""
	print("🎯 Showing final detailed results...")
	
	# Store score data in QuizManager for persistence
	QuizManager.store_quiz_results(
		"Semining_Quiz_1.2",
		score,
		correct_answers.size(),
		user_answers,
		correct_answers
	)
	
	# Navigate to completion screen
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://src/scenes/Quiz/Semining/Semining_Quiz_Result.tscn")

# Legacy function for compatibility
func _on_option_a_pressed():
	"""Legacy function - redirects to new submit handler"""
	_on_submit_pressed()
