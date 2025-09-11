extends Control

"""
Semining_Quiz_Result.gd
Results screen for Semining enumeration quiz, following Midterm_Quiz_Result reference.
Displays detailed results with individual answer feedback and navigation options.
"""

# UI Node references
@onready var score_label: Label = $MainContainer/ScorePanel/ScoreContainer/ScoreDisplay/ScoreLabel
@onready var percentage_label: Label = $MainContainer/ScorePanel/ScoreContainer/ScoreDisplay/PercentageLabel
@onready var grade_label: Label = $MainContainer/ScorePanel/ScoreContainer/ScoreDisplay/GradeLabel
@onready var performance_label: Label = $MainContainer/ScorePanel/ScoreContainer/PerformanceLabel
@onready var results_list: VBoxContainer = $MainContainer/ScorePanel/ScoreContainer/DetailedResults/ResultsList
@onready var main_container: VBoxContainer = $MainContainer

# Animation properties
var entrance_tween: Tween

func _ready() -> void:
	print("🎓 Semining Quiz Results loaded")
	setup_ui_animations()
	load_quiz_results()
	animate_entrance()

func setup_ui_animations() -> void:
	"""Setup initial UI state for entrance animations"""
	main_container.modulate.a = 0.0
	main_container.scale = Vector2(0.8, 0.8)

func animate_entrance() -> void:
	"""Animate UI entrance with smooth effects"""
	if entrance_tween:
		entrance_tween.kill()
	
	entrance_tween = create_tween()
	entrance_tween.set_parallel(true)
	
	# Main container animation
	entrance_tween.tween_property(main_container, "modulate:a", 1.0, 0.8)
	entrance_tween.tween_property(main_container, "scale", Vector2.ONE, 0.8)
	entrance_tween.set_ease(Tween.EASE_OUT)
	entrance_tween.set_trans(Tween.TRANS_BACK)

func load_quiz_results() -> void:
	"""Load and display quiz results from QuizManager"""
	if not QuizManager:
		print("❌ QuizManager not available!")
		display_fallback_results()
		return
	
	var latest_score = QuizManager.get_latest_score()
	if latest_score.is_empty():
		print("❌ No quiz results found!")
		display_fallback_results()
		return
	
	print("✅ Loading Semining quiz results: %s" % latest_score)
	display_quiz_results(latest_score)

func display_quiz_results(score_data: Dictionary) -> void:
	"""Display comprehensive quiz results"""
	# Update score display
	var correct = score_data.get("correct_answers", 0)
	var total = score_data.get("total_questions", 8)
	var percentage = score_data.get("percentage", 0.0)
	var grade = score_data.get("letter_grade", "F")
	
	score_label.text = "%d/%d" % [correct, total]
	percentage_label.text = "(%.1f%%)" % percentage
	grade_label.text = "Grade: %s" % grade
	
	# Update performance message and color
	var performance_msg = get_performance_message(percentage)
	performance_label.text = performance_msg
	update_grade_colors(percentage)
	
	# Display detailed answer results
	display_detailed_results(score_data)
	
	print("📊 Displayed results: %d/%d (%.1f%%) - %s" % [correct, total, percentage, grade])

func display_detailed_results(score_data: Dictionary) -> void:
	"""Display detailed per-question results"""
	var answers_data = score_data.get("answers", [])
	
	if answers_data.is_empty():
		var no_details = Label.new()
		no_details.text = "📝 Quiz completed successfully!"
		no_details.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		results_list.add_child(no_details)
		return
	
	for i in range(answers_data.size()):
		var answer = answers_data[i]
		create_answer_result_item(i + 1, answer)

func create_answer_result_item(question_num: int, answer_data: Dictionary) -> void:
	"""Create individual answer result display"""
	var container = HBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Question number
	var q_label = Label.new()
	q_label.text = "Q%d:" % question_num
	q_label.custom_minimum_size.x = 50
	container.add_child(q_label)
	
	# User answer
	var user_answer = answer_data.get("selected", "No answer")
	var correct_answer = answer_data.get("correct", "Unknown")
	var is_correct = user_answer.to_lower().strip_edges() == correct_answer.to_lower().strip_edges()
	
	var answer_label = Label.new()
	answer_label.text = "Your answer: %s" % user_answer
	answer_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Color-code based on correctness
	if is_correct:
		answer_label.modulate = Color.GREEN
		answer_label.text += " ✅"
	else:
		answer_label.modulate = Color.RED
		answer_label.text += " ❌ (Correct: %s)" % correct_answer
	
	container.add_child(answer_label)
	results_list.add_child(container)
	
	# Add spacing
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 10
	results_list.add_child(spacer)

func get_performance_message(percentage: float) -> String:
	"""Get performance message based on score percentage"""
	if percentage >= 95: return "🏆 Outstanding Performance!"
	elif percentage >= 90: return "🌟 Excellent Work!"
	elif percentage >= 80: return "👍 Great Job!"
	elif percentage >= 70: return "😊 Good Effort!"
	elif percentage >= 60: return "📚 Keep Practicing!"
	else: return "💪 Review and Try Again!"

func update_grade_colors(percentage: float) -> void:
	"""Update UI colors based on performance"""
	var color: Color
	
	if percentage >= 90:
		color = Color.GREEN
	elif percentage >= 80:
		color = Color.YELLOW
	elif percentage >= 70:
		color = Color.ORANGE
	else:
		color = Color.RED
	
	grade_label.modulate = color
	performance_label.modulate = color

func display_fallback_results() -> void:
	"""Display fallback results when data is unavailable"""
	score_label.text = "Quiz Completed"
	percentage_label.text = ""
	grade_label.text = "Results Saved"
	performance_label.text = "📝 Thank you for taking the quiz!"
	performance_label.modulate = Color.WHITE
	
	var fallback_msg = Label.new()
	fallback_msg.text = "Your quiz has been completed and results have been saved.\nCheck with your instructor for detailed feedback."
	fallback_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fallback_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	results_list.add_child(fallback_msg)

func _on_retry_button_pressed() -> void:
	"""Handle retry quiz button"""
	print("🔄 Retrying Semining Quiz...")
	
	# Navigate back to quiz start
	get_tree().change_scene_to_file("res://src/scenes/Quiz/Semining/Semining_Quiz_1.1.tscn")

func _on_menu_button_pressed() -> void:
	"""Handle return to main menu button"""
	print("🏠 Returning to Main Menu...")
	
	# Navigate to main menu
	get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn")

func _on_continue_button_pressed() -> void:
	"""Handle continue button"""
	print("➡️ Continuing to next section...")
	
	# For now, return to main menu
	# In the future, this could navigate to the next lesson/quiz
	get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn")

func _input(event: InputEvent) -> void:
	"""Handle keyboard shortcuts"""
	if event.is_action_pressed("ui_cancel"):
		_on_menu_button_pressed()
	elif event.is_action_pressed("ui_accept"):
		_on_continue_button_pressed()
