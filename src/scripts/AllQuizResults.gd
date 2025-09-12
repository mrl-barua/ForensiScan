extends Control

"""
AllQuizResults.gd
Comprehensive quiz results dashboard that displays all quiz scores from both Prelim and Midterm sections.
Integrates with QuizManager for data retrieval and provides summary statistics.
"""

# UI References
@onready var prelim_results_list = $MainContainer/ContentContainer/PrelimSection/PrelimPanel/PrelimScrollContainer/PrelimResultsList
@onready var midterm_results_list = $MainContainer/ContentContainer/MidtermSection/MidtermPanel/MidtermScrollContainer/MidtermResultsList
@onready var semining_results_list = $MainContainer/ContentContainer/SeminingSection/MidtermPanel/MidtermScrollContainer/MidtermResultsList
@onready var total_quizzes_label = $MainContainer/SummaryPanel/SummaryContainer/TotalQuizzesLabel
@onready var average_score_label = $MainContainer/SummaryPanel/SummaryContainer/AverageScoreLabel
@onready var best_score_label = $MainContainer/SummaryPanel/SummaryContainer/BestScoreLabel

# Animation and styling
var fade_in_duration = 0.6
var stagger_delay = 0.1

func _ready():
	"""Initialize the results dashboard with fade-in animation"""
	print("=== AllQuizResults Scene Initialized ===")
	
	# Start with transparent UI for fade-in effect
	modulate.a = 0.0
	
	# Load and display all quiz results
	load_quiz_results()
	
	# Animate entrance
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_in_duration)
	tween.tween_callback(animate_result_cards)

func load_quiz_results():
	"""Load and display all quiz results from QuizManager"""
	print("Loading quiz results from QuizManager...")
	
	# Clear existing results
	clear_results_lists()
	
	# Get all stored results from QuizManager
	var all_results = get_all_quiz_results()
	
	# Separate results by quiz type
	var prelim_results = []
	var midterm_results = []
	var semining_results = []
	
	for result in all_results:
		if result.quiz_type == "prelim":
			prelim_results.append(result)
		elif result.quiz_type == "midterm":
			midterm_results.append(result)
		elif result.quiz_type == "semining":
			semining_results.append(result)
	
	# Sort results by timestamp (most recent first)
	prelim_results.sort_custom(func(a, b): return a.timestamp > b.timestamp)
	midterm_results.sort_custom(func(a, b): return a.timestamp > b.timestamp)
	semining_results.sort_custom(func(a, b): return a.timestamp > b.timestamp)
	
	# Display results
	display_prelim_results(prelim_results)
	display_midterm_results(midterm_results)
	display_semining_results(semining_results)
	
	# Update summary statistics
	update_summary_statistics(all_results)

func get_all_quiz_results() -> Array:
	"""Retrieve all quiz results from QuizManager with fallback for missing data"""
	var all_results = []
	
	# Check if QuizManager exists and has quiz_results
	if QuizManager and QuizManager.has_method("get_all_results"):
		all_results = QuizManager.get_all_results()
	elif QuizManager and "quiz_results" in QuizManager:
		# Manual extraction if get_all_results doesn't exist
		for quiz_name in QuizManager.quiz_results.keys():
			var result_data = QuizManager.quiz_results[quiz_name]
			var result = {
				"quiz_name": quiz_name,
				"quiz_type": determine_quiz_type(quiz_name),
				"score": result_data.get("score", 0),
				"percentage": result_data.get("percentage", 0.0),
				"grade": result_data.get("grade", "F"),
				"total_questions": result_data.get("total_questions", 0),
				"correct_answers": result_data.get("correct_answers", 0),
				"timestamp": result_data.get("timestamp", "Unknown")
			}
			all_results.append(result)
	else:
		print("Warning: QuizManager not available or no quiz_results found")
		# Create sample data for demonstration
		all_results = create_sample_results()
	
	print("Total quiz results found: ", all_results.size())
	return all_results

func determine_quiz_type(quiz_name: String) -> String:
	"""Determine if a quiz is prelim, midterm, or semining based on its name"""
	var name_lower = quiz_name.to_lower()
	if "prelim" in name_lower or "Prelim" in quiz_name:
		return "prelim"
	elif "midterm" in name_lower or "Midterm" in quiz_name:
		return "midterm"
	elif "semining" in name_lower or "Semining" in quiz_name:
		return "semining"
	else:
		return "unknown"

func create_sample_results() -> Array:
	"""Create sample results for demonstration when no data is available"""
	return [
		{
			"quiz_name": "Prelim Quiz 1.1",
			"quiz_type": "prelim",
			"score": 8,
			"percentage": 80.0,
			"grade": "B",
			"total_questions": 10,
			"correct_answers": 8,
			"timestamp": "2024-01-15 14:30"
		},
		{
			"quiz_name": "Midterm Quiz 1.1",
			"quiz_type": "midterm",
			"score": 9,
			"percentage": 90.0,
			"grade": "A",
			"total_questions": 10,
			"correct_answers": 9,
			"timestamp": "2024-01-20 16:45"
		},
		{
			"quiz_name": "Semining Quiz 1.1",
			"quiz_type": "semining",
			"score": 7,
			"percentage": 87.5,
			"grade": "B+",
			"total_questions": 8,
			"correct_answers": 7,
			"timestamp": "2024-01-25 10:15"
		},
		{
			"quiz_name": "Semining Quiz 1.2",
			"quiz_type": "semining",
			"score": 6,
			"percentage": 75.0,
			"grade": "B",
			"total_questions": 8,
			"correct_answers": 6,
			"timestamp": "2024-01-26 11:30"
		}
	]

func clear_results_lists():
	"""Clear all existing result cards from all lists"""
	# Clear Prelim results
	for child in prelim_results_list.get_children():
		child.queue_free()
	
	# Clear Midterm results
	for child in midterm_results_list.get_children():
		child.queue_free()
	
	# Clear Semining results
	for child in semining_results_list.get_children():
		child.queue_free()

func display_prelim_results(results: Array):
	"""Display Prelim quiz results with animated cards"""
	print("Displaying ", results.size(), " Prelim results")
	
	if results.is_empty():
		add_no_results_card(prelim_results_list, "No Prelim quiz results yet")
		return
	
	for i in range(results.size()):
		var result = results[i]
		var card = create_result_card(result, i)
		prelim_results_list.add_child(card)

func display_midterm_results(results: Array):
	"""Display Midterm quiz results with animated cards"""
	print("Displaying ", results.size(), " Midterm results")
	
	if results.is_empty():
		add_no_results_card(midterm_results_list, "No Midterm quiz results yet")
		return
	
	for i in range(results.size()):
		var result = results[i]
		var card = create_result_card(result, i)
		midterm_results_list.add_child(card)

func display_semining_results(results: Array):
	"""Display Semining quiz results with animated cards"""
	print("Displaying ", results.size(), " Semining results")
	
	if results.is_empty():
		add_no_results_card(semining_results_list, "No Semining quiz results yet")
		return
	
	for i in range(results.size()):
		var result = results[i]
		var card = create_semining_result_card(result, i)
		semining_results_list.add_child(card)

func create_result_card(result: Dictionary, index: int) -> Panel:
	"""Create a styled result card for displaying quiz results"""
	var card = Panel.new()
	card.custom_minimum_size = Vector2(0, 120)
	
	# Create card style
	var style = StyleBoxFlat.new()
	style.bg_color = get_grade_color(result.grade)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color.WHITE * 0.3
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	card.add_theme_stylebox_override("panel", style)
	
	# Create card content
	var vbox = VBoxContainer.new()
	card.add_child(vbox)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.set_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 15)
	
	# Quiz name and timestamp
	var header_container = HBoxContainer.new()
	vbox.add_child(header_container)
	
	var name_label = Label.new()
	name_label.text = result.quiz_name
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	header_container.add_child(name_label)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_container.add_child(spacer)
	
	var timestamp_label = Label.new()
	timestamp_label.text = str(result.timestamp)
	timestamp_label.add_theme_font_size_override("font_size", 12)
	timestamp_label.add_theme_color_override("font_color", Color.WHITE * 0.8)
	header_container.add_child(timestamp_label)
	
	# Score information
	var score_container = HBoxContainer.new()
	vbox.add_child(score_container)
	
	var score_label = Label.new()
	score_label.text = "Score: %d/%d" % [result.correct_answers, result.total_questions]
	score_label.add_theme_font_size_override("font_size", 16)
	score_label.add_theme_color_override("font_color", Color.WHITE)
	score_container.add_child(score_label)
	
	var spacer2 = Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	score_container.add_child(spacer2)
	
	var percentage_label = Label.new()
	percentage_label.text = "%.1f%%" % result.percentage
	percentage_label.add_theme_font_size_override("font_size", 16)
	percentage_label.add_theme_color_override("font_color", Color.WHITE)
	score_container.add_child(percentage_label)
	
	var spacer3 = Control.new()
	spacer3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	score_container.add_child(spacer3)
	
	var grade_label = Label.new()
	grade_label.text = "Grade: %s" % result.grade
	grade_label.add_theme_font_size_override("font_size", 18)
	grade_label.add_theme_color_override("font_color", Color.WHITE)
	score_container.add_child(grade_label)
	
	# Start invisible for animation
	card.modulate.a = 0.0
	card.scale = Vector2(0.8, 0.8)
	
	return card

func create_semining_result_card(result: Dictionary, index: int) -> Panel:
	"""Create a specialized result card for Semining quizzes with enhanced styling"""
	var card = Panel.new()
	card.custom_minimum_size = Vector2(0, 140)  # Slightly taller for more content
	
	# Create special Semining card style with gradient effect
	var style = StyleBoxFlat.new()
	style.bg_color = get_semining_grade_color(result.grade)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.4, 0.7, 1.0, 0.8)  # Special blue border for Semining
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	card.add_theme_stylebox_override("panel", style)
	
	# Create card content with special Semining layout
	var vbox = VBoxContainer.new()
	card.add_child(vbox)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.set_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 15)
	
	# Quiz name and Semining badge
	var header_container = HBoxContainer.new()
	vbox.add_child(header_container)
	
	var badge_label = Label.new()
	badge_label.text = "🔬 SEMINING"
	badge_label.add_theme_font_size_override("font_size", 12)
	badge_label.add_theme_color_override("font_color", Color(0.4, 0.7, 1.0, 1.0))
	header_container.add_child(badge_label)
	
	var spacer_badge = Control.new()
	spacer_badge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_container.add_child(spacer_badge)
	
	var timestamp_label = Label.new()
	timestamp_label.text = str(result.timestamp)
	timestamp_label.add_theme_font_size_override("font_size", 12)
	timestamp_label.add_theme_color_override("font_color", Color.WHITE * 0.8)
	header_container.add_child(timestamp_label)
	
	# Quiz name
	var name_label = Label.new()
	name_label.text = result.quiz_name
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(name_label)
	
	# Score information with enhanced details
	var score_container = HBoxContainer.new()
	vbox.add_child(score_container)
	
	var score_label = Label.new()
	score_label.text = "Score: %d/%d" % [result.correct_answers, result.total_questions]
	score_label.add_theme_font_size_override("font_size", 16)
	score_label.add_theme_color_override("font_color", Color.WHITE)
	score_container.add_child(score_label)
	
	var spacer2 = Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	score_container.add_child(spacer2)
	
	var percentage_label = Label.new()
	percentage_label.text = "%.1f%%" % result.percentage
	percentage_label.add_theme_font_size_override("font_size", 16)
	percentage_label.add_theme_color_override("font_color", Color.WHITE)
	score_container.add_child(percentage_label)
	
	var spacer3 = Control.new()
	spacer3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	score_container.add_child(spacer3)
	
	var grade_label = Label.new()
	grade_label.text = "Grade: %s" % result.grade
	grade_label.add_theme_font_size_override("font_size", 18)
	grade_label.add_theme_color_override("font_color", Color.WHITE)
	score_container.add_child(grade_label)
	
	# Performance indicator for Semining
	var performance_container = HBoxContainer.new()
	vbox.add_child(performance_container)
	
	var performance_label = Label.new()
	var performance_text = get_semining_performance_text(result.percentage)
	performance_label.text = "📊 " + performance_text
	performance_label.add_theme_font_size_override("font_size", 14)
	performance_label.add_theme_color_override("font_color", get_performance_color(result.percentage))
	performance_container.add_child(performance_label)
	
	# Start invisible for animation
	card.modulate.a = 0.0
	card.scale = Vector2(0.8, 0.8)
	
	return card

func get_semining_grade_color(grade: String) -> Color:
	"""Get special color scheme for Semining quiz grades"""
	match grade:
		"A+", "A":
			return Color(0.1, 0.5, 0.8, 0.9)  # Deep blue for excellence
		"A-", "B+", "B":
			return Color(0.1, 0.4, 0.6, 0.9)  # Medium blue for good performance
		"B-", "C+", "C":
			return Color(0.3, 0.4, 0.5, 0.9)  # Neutral blue-gray
		"C-", "D+", "D":
			return Color(0.5, 0.3, 0.4, 0.9)  # Purple-gray for below average
		"F":
			return Color(0.5, 0.2, 0.3, 0.9)  # Dark red for failing
		_:
			return Color(0.3, 0.3, 0.4, 0.9)  # Default gray

func get_semining_performance_text(percentage: float) -> String:
	"""Get performance description for Semining quizzes"""
	if percentage >= 90.0:
		return "Excellent Analysis Skills"
	elif percentage >= 80.0:
		return "Good Understanding"
	elif percentage >= 70.0:
		return "Satisfactory Progress"
	elif percentage >= 60.0:
		return "Needs Improvement"
	else:
		return "Requires Additional Study"

func get_performance_color(percentage: float) -> Color:
	"""Get color for performance text based on percentage"""
	if percentage >= 90.0:
		return Color(0.2, 0.8, 0.2, 1.0)  # Bright green
	elif percentage >= 80.0:
		return Color(0.2, 0.6, 0.8, 1.0)  # Blue
	elif percentage >= 70.0:
		return Color(0.8, 0.8, 0.2, 1.0)  # Yellow
	elif percentage >= 60.0:
		return Color(0.8, 0.4, 0.2, 1.0)  # Orange
	else:
		return Color(0.8, 0.2, 0.2, 1.0)  # Red

func add_no_results_card(parent: Node, message: String):
	"""Add a card indicating no results are available"""
	var card = Panel.new()
	card.custom_minimum_size = Vector2(0, 80)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.3, 0.5)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color.WHITE * 0.2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	card.add_theme_stylebox_override("panel", style)
	
	var label = Label.new()
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color.WHITE * 0.7)
	card.add_child(label)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	parent.add_child(card)

func get_grade_color(grade: String) -> Color:
	"""Get color based on grade for result cards"""
	match grade:
		"A":
			return Color(0.1, 0.6, 0.1, 0.8)  # Green
		"B":
			return Color(0.1, 0.4, 0.6, 0.8)  # Blue
		"C":
			return Color(0.6, 0.6, 0.1, 0.8)  # Yellow
		"D":
			return Color(0.6, 0.3, 0.1, 0.8)  # Orange
		"F":
			return Color(0.6, 0.1, 0.1, 0.8)  # Red
		_:
			return Color(0.3, 0.3, 0.3, 0.8)  # Gray

func update_summary_statistics(all_results: Array):
	"""Update the summary statistics panel"""
	if all_results.is_empty():
		total_quizzes_label.text = "Total Quizzes: 0"
		average_score_label.text = "Average Score: 0%"
		best_score_label.text = "Best Score: 0%"
		return
	
	var total_quizzes = all_results.size()
	var total_percentage = 0.0
	var best_percentage = 0.0
	
	for result in all_results:
		total_percentage += result.percentage
		if result.percentage > best_percentage:
			best_percentage = result.percentage
	
	var average_percentage = total_percentage / total_quizzes
	
	total_quizzes_label.text = "Total Quizzes: %d" % total_quizzes
	average_score_label.text = "Average Score: %.1f%%" % average_percentage
	best_score_label.text = "Best Score: %.1f%%" % best_percentage
	
	print("Summary: %d quizzes, %.1f%% average, %.1f%% best" % [total_quizzes, average_percentage, best_percentage])

func animate_result_cards():
	"""Animate the appearance of result cards with stagger effect"""
	var all_cards = []
	
	# Collect all cards from all lists
	all_cards.append_array(prelim_results_list.get_children())
	all_cards.append_array(midterm_results_list.get_children())
	all_cards.append_array(semining_results_list.get_children())
	
	# Animate each card with stagger
	for i in range(all_cards.size()):
		var card = all_cards[i]
		await get_tree().create_timer(stagger_delay * i).timeout
		
		var tween = create_tween()
		tween.parallel().tween_property(card, "modulate:a", 1.0, 0.4)
		tween.parallel().tween_property(card, "scale", Vector2.ONE, 0.4)
		tween.tween_callback(func(): add_hover_effect(card))

func add_hover_effect(card: Panel):
	"""Add subtle hover effect to result cards"""
	card.mouse_entered.connect(func(): 
		var tween = create_tween()
		tween.tween_property(card, "scale", Vector2(1.02, 1.02), 0.1)
	)
	
	card.mouse_exited.connect(func(): 
		var tween = create_tween()
		tween.tween_property(card, "scale", Vector2.ONE, 0.1)
	)

func _on_back_button_pressed():
	"""Return to main menu with smooth transition"""
	print("Back to Main Menu button pressed")
	
	# Fade out effect
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn"))

func _on_clear_data_button_pressed():
	"""Clear all quiz data with confirmation"""
	print("Clear Data button pressed")
	
	# Create confirmation dialog
	var dialog = AcceptDialog.new()
	dialog.dialog_text = "Are you sure you want to clear all quiz results?\nThis action cannot be undone!"
	dialog.title = "Confirm Clear Data"
	add_child(dialog)
	
	# Add cancel button
	dialog.add_cancel_button("Cancel")
	
	dialog.confirmed.connect(func():
		clear_all_quiz_data()
		dialog.queue_free()
	)
	
	dialog.canceled.connect(func():
		print("Clear data operation canceled")
		dialog.queue_free()
	)
	
	dialog.popup_centered()

func clear_all_quiz_data():
	"""Clear all stored quiz data from QuizManager"""
	print("Clearing all quiz data...")
	
	if QuizManager and QuizManager.has_method("clear_all_results"):
		QuizManager.clear_all_results()
	elif QuizManager and "quiz_results" in QuizManager:
		QuizManager.quiz_results.clear()
	
	# Reload the display
	load_quiz_results()
	
	print("All quiz data cleared successfully!")

# Debug function for testing
func _input(event):
	"""Debug input handler"""
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			print("=== Reloading Quiz Results (Debug) ===")
			load_quiz_results()
		elif event.keycode == KEY_T:
			print("=== Adding Test Data (Debug) ===")
			add_test_data()

func add_test_data():
	"""Add sample test data to QuizManager for testing purposes"""
	print("Adding test data to QuizManager...")
	
	if QuizManager:
		# Use the new force save test data function if available
		if QuizManager.has_method("force_save_test_data"):
			QuizManager.force_save_test_data()
		else:
			# Fallback to manual test data creation
			QuizManager.store_quiz_results("Prelim_Quiz_Complete", 8, 10, [], [])
			QuizManager.store_quiz_results("Midterm_Quiz_1.1", 9, 10, [], [])
			QuizManager.store_quiz_results("Semining_Quiz_1.1", 7, 8, [], [])
			QuizManager.store_quiz_results("Semining_Quiz_1.2", 6, 8, [], [])
		
		print("Test data added successfully!")
		print("=== QuizManager Debug Info ===")
		QuizManager.print_debug_info()
		print("==============================")
		
		# Reload the display
		load_quiz_results()
	else:
		print("Warning: QuizManager not available for adding test data")
