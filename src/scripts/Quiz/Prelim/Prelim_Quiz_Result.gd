extends Node2D

# Enhanced Quiz Result Screen
# Modern UI/UX with comprehensive result display and interactive features

# Node references for the new UI structure
@onready var score_label: Label = $MainContainer/MainPanel/ContentContainer/MiddleSection/LeftColumn/ScoreSection/ScorePanel/ScoreContent/ScoreLabel
@onready var score_percentage: Label = $MainContainer/MainPanel/ContentContainer/MiddleSection/LeftColumn/ScoreSection/ScorePanel/ScoreContent/ScorePercentage
@onready var history_text: RichTextLabel = $MainContainer/MainPanel/ContentContainer/MiddleSection/RightColumn/HistorySection/HistoryPanel/HistoryContent/ScrollContainer/HistoryText
@onready var license_name: Label = $MainContainer/MainPanel/ContentContainer/MiddleSection/LeftColumn/DetailsSection/DetailsPanel/DetailsContent/StudentInfo/Name
@onready var license_semester: Label = $MainContainer/MainPanel/ContentContainer/MiddleSection/LeftColumn/DetailsSection/DetailsPanel/DetailsContent/StudentInfo/Semester
@onready var license_registered_device: Label = $MainContainer/MainPanel/ContentContainer/MiddleSection/LeftColumn/DetailsSection/DetailsPanel/DetailsContent/StudentInfo/DeviceId
@onready var pdf_button: Button = $MainContainer/MainPanel/ContentContainer/BottomSection/PDFButton
@onready var retry_button: Button = $MainContainer/MainPanel/ContentContainer/BottomSection/RetryButton
@onready var main_menu_button: Button = $MainContainer/MainPanel/ContentContainer/BottomSection/MainMenuButton
@onready var main_container: Control = $MainContainer

# Animation management
var entrance_tween: Tween
var button_tweens: Dictionary = {}

func _ready():
	setup_animations()
	setup_button_connections()
	await display_results_with_animation()

func setup_animations():
	"""Setup entrance animations for modern feel"""
	# Set initial state for entrance animation
	main_container.modulate.a = 0.0
	main_container.scale = Vector2(0.9, 0.9)

func setup_button_connections():
	"""Connect button signals and hover effects"""
	pdf_button.pressed.connect(_on_pdf_button_pressed)
	retry_button.pressed.connect(_on_retry_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	
	# Setup button hover effects
	setup_button_hover_effects(pdf_button)
	setup_button_hover_effects(retry_button)
	setup_button_hover_effects(main_menu_button)
	
	# Connect PDF generation signals
	PDFGenerator.pdf_generated.connect(_on_pdf_generated)
	PDFGenerator.pdf_generation_failed.connect(_on_pdf_generation_failed)

func setup_button_hover_effects(button: Button):
	"""Setup modern hover effects for buttons"""
	button.mouse_entered.connect(_on_button_hover.bind(button))
	button.mouse_exited.connect(_on_button_unhover.bind(button))

func _on_button_hover(button: Button):
	"""Enhanced button hover effect"""
	var button_id = button.get_instance_id()
	if button_tweens.has(button_id):
		button_tweens[button_id].kill()
	
	button_tweens[button_id] = create_tween()
	var tween = button_tweens[button_id]
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1.02, 1.02), 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property(button, "rotation", deg_to_rad(0.5), 0.2).set_trans(Tween.TRANS_SINE)

func _on_button_unhover(button: Button):
	"""Enhanced button unhover effect"""
	var button_id = button.get_instance_id()
	if button_tweens.has(button_id):
		button_tweens[button_id].kill()
	
	button_tweens[button_id] = create_tween()
	var tween = button_tweens[button_id]
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property(button, "rotation", 0.0, 0.2).set_trans(Tween.TRANS_SINE)

func display_results_with_animation():
	"""Display results with smooth animations"""
	save_performance()
	
	# Start entrance animation
	if entrance_tween:
		entrance_tween.kill()
	
	entrance_tween = create_tween()
	entrance_tween.set_parallel(true)
	
	# Fade in and scale up main container
	entrance_tween.tween_property(main_container, "modulate:a", 1.0, 0.8)
	entrance_tween.tween_property(main_container, "scale", Vector2(1.0, 1.0), 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Wait for entrance animation to complete
	await entrance_tween.finished
	
	# Display score with animation
	await display_score_animated()
	
	# Display student info
	await display_student_info()
	
	# Display answer history
	await display_answer_history()

func display_score_animated():
	"""Display score with counting animation"""
	var final_score = QuizManager.get_score()
	var total_questions = QuizManager.current_set.size()
	var percentage = (float(final_score) / float(total_questions)) * 100.0
	
	# Animate score counting
	var score_tween = create_tween()
	score_tween.tween_method(update_score_display, 0, final_score, 1.5)
	
	# Set final percentage and grade
	await score_tween.finished
	
	var grade_text = get_grade_text(percentage)
	score_percentage.text = "%.0f%% - %s" % [percentage, grade_text]
	
	# Animate percentage display
	score_percentage.modulate.a = 0.0
	var percentage_tween = create_tween()
	percentage_tween.tween_property(score_percentage, "modulate:a", 1.0, 0.5)
	await percentage_tween.finished

func update_score_display(current_score: int):
	"""Update score display during counting animation"""
	var total_questions = QuizManager.current_set.size()
	score_label.text = "%d/%d" % [current_score, total_questions]

func get_grade_text(percentage: float) -> String:
	"""Get grade text based on percentage"""
	if percentage >= 90:
		return "Outstanding! 🌟"
	elif percentage >= 80:
		return "Excellent! 🎉"
	elif percentage >= 70:
		return "Good Work! 👍"
	elif percentage >= 60:
		return "Satisfactory 📚"
	else:
		return "Needs Improvement 💪"

func display_student_info():
	"""Display student information with animation"""
	var details = LicenseProcessor.get_license_details()
	
	var info_tween = create_tween()
	info_tween.set_parallel(true)
	
	if details.size() > 0:
		license_name.text = "👤 " + str(details.get("name", "Unknown"))
		license_semester.text = "🎓 " + str(details.get("semester", "N/A"))
		license_registered_device.text = "💻 " + str(details.get("device_id", "Not Registered"))
		
		# Animate each info line
		for node in [license_name, license_semester, license_registered_device]:
			node.modulate.a = 0.0
			info_tween.tween_property(node, "modulate:a", 1.0, 0.5).set_delay(0.2)
	else:
		license_name.text = "❌ No license found"
		license_semester.text = "Please register your license"
		license_registered_device.text = "Contact administrator for assistance"
		
		# Set warning color
		for node in [license_name, license_semester, license_registered_device]:
			node.modulate = Color(1.0, 0.6, 0.4, 0.0)
			info_tween.tween_property(node, "modulate:a", 1.0, 0.5).set_delay(0.2)
	
	await info_tween.finished

func display_answer_history():
	"""Display answer history with enhanced formatting"""
	var answers = QuizManager.get_answer_history()
	var history_bbcode = "[center][b]📝 DETAILED REVIEW[/b][/center]\n\n"
	
	for i in range(answers.size()):
		var entry = answers[i]
		var question_num = i + 1
		var is_correct = entry["selected"] == entry["correct"]
		
		# Format each question entry with colors and icons
		history_bbcode += "[b]Question %d:[/b]\n" % question_num
		history_bbcode += "%s\n\n" % entry["question"]
		
		if is_correct:
			history_bbcode += "[color=#4CAF50]✅ Your Answer: %s[/color]\n" % entry["selected"]
			history_bbcode += "[color=#81C784]✓ Correct![/color]\n"
		else:
			history_bbcode += "[color=#F44336]❌ Your Answer: %s[/color]\n" % (entry["selected"] if entry["selected"] != "" else "No answer")
			history_bbcode += "[color=#4CAF50]✓ Correct Answer: %s[/color]\n" % entry["correct"]
		
		# Create separator line
		var separator = ""
		for j in range(50):
			separator += "─"
		history_bbcode += "\n" + separator + "\n\n"
	
	# Animate history text appearance
	history_text.modulate.a = 0.0
	history_text.text = history_bbcode
	
	var history_tween = create_tween()
	history_tween.tween_property(history_text, "modulate:a", 1.0, 0.8)
	await history_tween.finished

func save_performance():
	"""Save quiz performance data"""
	var cfg = ConfigFile.new()
	var timestamp = Time.get_datetime_string_from_system()
	
	cfg.set_value("performance", "score", QuizManager.get_score())
	cfg.set_value("performance", "total_questions", QuizManager.current_set.size())
	cfg.set_value("performance", "percentage", (float(QuizManager.get_score()) / float(QuizManager.current_set.size())) * 100.0)
	cfg.set_value("performance", "answers", QuizManager.get_answer_history())
	cfg.set_value("performance", "timestamp", timestamp)
	cfg.set_value("performance", "student_info", LicenseProcessor.get_license_details())
	
	cfg.save("user://prelim_performance.cfg")
	print("Quiz performance saved successfully")

func _on_retry_button_pressed():
	"""Handle retry quiz button"""
	print("Retaking quiz...")
	# Add confirmation dialog or direct restart
	get_tree().change_scene_to_file("res://src/scenes/Quiz/Prelim/Prelim_Quiz_1.1.tscn")

func _on_main_menu_button_pressed():
	"""Handle main menu button"""
	print("Returning to main menu...")
	get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn")

func _on_pdf_button_pressed():
	"""Handle PDF generation button"""
	print("Generating PDF report...")
	
	# First run test to see what data we have
	print("=== RUNNING PDF GENERATION TEST ===")
	PDFGenerator.test_pdf_generation()
	
	# Disable button and show loading state
	pdf_button.disabled = true
	pdf_button.text = "📄 GENERATING..."
	
	# Start PDF generation
	PDFGenerator.generate_prelim_results_pdf()

func _on_pdf_generated(file_path: String):
	"""Handle successful PDF generation"""
	print("PDF generated successfully: ", file_path)
	
	# Re-enable button and show success state
	pdf_button.disabled = false
	
	if OS.get_name() == "Android":
		pdf_button.text = "📄 REPORT SAVED"
		show_notification("✅ Report saved as text file!", Color.GREEN)
		
		# Show Android-specific instructions
		await get_tree().create_timer(2.0).timeout
		show_notification("📱 Check app data folder for the report file", Color.BLUE)
	else:
		pdf_button.text = "📄 OPEN REPORT FOLDER"
		show_notification("✅ HTML Report Generated Successfully!", Color.GREEN)
		
		# Change button functionality to open report location
		if pdf_button.pressed.is_connected(_on_pdf_button_pressed):
			pdf_button.pressed.disconnect(_on_pdf_button_pressed)
		pdf_button.pressed.connect(_on_open_report_folder)

func _on_pdf_generation_failed(error_message: String):
	"""Handle PDF generation failure"""
	print("PDF generation failed: ", error_message)
	
	# Re-enable button and show error state
	pdf_button.disabled = false
	pdf_button.text = "❌ GENERATION FAILED"
	
	# Show error notification
	show_notification("❌ PDF Generation Failed: " + error_message, Color.RED)
	
	# Reset button after a delay
	await get_tree().create_timer(3.0).timeout
	pdf_button.text = "📄 RETRY PDF GENERATION"

func _on_open_report_folder():
	"""Open the reports folder"""
	if OS.get_name() == "Android":
		show_notification("📱 Report saved in app data directory", Color.BLUE)
		print("Android - Report location: ", OS.get_user_data_dir() + "/reports/")
	else:
		PDFGenerator.open_report_location()
		show_notification("📁 Opening reports folder...", Color.BLUE)

func show_notification(message: String, color: Color):
	"""Show a temporary notification to the user"""
	# Create a temporary notification label
	var notification = Label.new()
	notification.text = message
	notification.modulate = color
	notification.add_theme_font_override("font", load("res://src/styles/official_font.tres"))
	notification.add_theme_font_size_override("font_size", 16)
	notification.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Position the notification
	notification.anchors_preset = Control.PRESET_TOP_WIDE
	notification.offset_top = 20
	notification.offset_bottom = 50
	
	# Add to scene
	main_container.add_child(notification)
	
	# Animate in
	notification.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(notification, "modulate:a", 1.0, 0.3)
	
	# Remove after delay
	await get_tree().create_timer(3.0).timeout
	
	if notification and is_instance_valid(notification):
		var fade_tween = create_tween()
		fade_tween.tween_property(notification, "modulate:a", 0.0, 0.3)
		await fade_tween.finished
		notification.queue_free()
