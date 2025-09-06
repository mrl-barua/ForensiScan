extends Control

# Resume Progress Dialog
# Shows when user has previous progress and offers to continue or start fresh

signal resume_selected(lesson_type: String, lesson_number: int)
signal start_fresh_selected(lesson_type: String)
signal dialog_closed()

@onready var dialog_panel: Panel = $DialogPanel
@onready var title_label: Label = $DialogPanel/VBoxContainer/TitleLabel
@onready var message_label: RichTextLabel = $DialogPanel/VBoxContainer/MessageContainer/MessageLabel
@onready var progress_info_label: Label = $DialogPanel/VBoxContainer/MessageContainer/ProgressInfoLabel
@onready var resume_button: Button = $DialogPanel/VBoxContainer/ButtonContainer/ResumeButton
@onready var start_fresh_button: Button = $DialogPanel/VBoxContainer/ButtonContainer/StartFreshButton
@onready var cancel_button: Button = $DialogPanel/VBoxContainer/ButtonContainer/CancelButton

var current_lesson_type: String = ""
var resume_info: Dictionary = {}

var dialog_tween: Tween

func _ready():
	hide()
	setup_connections()

func setup_connections():
	"""Connect button signals"""
	resume_button.pressed.connect(_on_resume_button_pressed)
	start_fresh_button.pressed.connect(_on_start_fresh_button_pressed)
	cancel_button.pressed.connect(_on_cancel_button_pressed)

func show_resume_dialog(lesson_type: String):
	"""Show the resume dialog for a specific lesson type"""
	print("=== ResumeProgressDialog.show_resume_dialog called ===")
	print("Lesson type: ", lesson_type)
	
	current_lesson_type = lesson_type
	resume_info = ProgressManager.get_resume_info_for_lesson_type(lesson_type)
	
	print("Resume info in dialog for %s: " % lesson_type, resume_info)
	
	# Only show if there's actually progress to resume
	if resume_info.is_empty():
		print("No relevant progress for %s, emitting start_fresh_selected" % lesson_type)
		# No relevant progress, just start fresh
		start_fresh_selected.emit(lesson_type)
		return
	
	# Don't show dialog if user is at lesson 1 (no progress to resume)
	if resume_info.lesson_number <= 1:
		print("Lesson number <= 1 for %s, emitting start_fresh_selected" % lesson_type)
		start_fresh_selected.emit(lesson_type)
		return
	if resume_info.lesson_number <= 1:
		print("Lesson number <= 1, emitting start_fresh_selected")
		start_fresh_selected.emit(lesson_type)
		return
	
	print("Updating dialog content and showing...")
	update_dialog_content()
	
	# Force visibility for debugging
	visible = true
	modulate = Color(1, 1, 1, 1)
	z_index = 100
	
	print("Dialog show() called - visible: ", visible)
	print("Dialog modulate: ", modulate)
	print("Dialog z_index: ", z_index)
	animate_dialog_in()

func update_dialog_content():
	"""Update dialog content based on resume info"""
	if resume_info.is_empty():
		return
	
	var lesson_type_display = resume_info.lesson_type.capitalize()
	var lesson_number = resume_info.lesson_number
	var total_lessons = resume_info.total_lessons
	var timestamp = resume_info.get("timestamp", "")
	
	title_label.text = "Continue %s Lessons?" % lesson_type_display
	
	# Format timestamp for display
	var time_display = ""
	if timestamp != "":
		var datetime_parts = timestamp.split("T")
		if datetime_parts.size() >= 2:
			var date_part = datetime_parts[0]
			var time_part = datetime_parts[1].split(".")[0]  # Remove milliseconds
			time_display = "Last accessed: %s at %s" % [date_part, time_part]
	
	message_label.text = """[center]You have previous progress in [color=lightblue]%s lessons[/color].

Would you like to continue from where you left off or start fresh?[/center]""" % lesson_type_display
	
	progress_info_label.text = """📍 Last lesson: %s Lesson %d of %d
⏱️ %s""" % [lesson_type_display, lesson_number, total_lessons, time_display]
	
	resume_button.text = "📖 Continue from Lesson %d" % lesson_number
	start_fresh_button.text = "🔄 Start from Lesson 1"

func animate_dialog_in():
	"""Animate dialog appearance"""
	print("=== animate_dialog_in called ===")
	if dialog_tween:
		dialog_tween.kill()
	
	# Force panel visibility for debugging
	dialog_panel.visible = true
	dialog_panel.modulate = Color(1, 1, 1, 1)
	dialog_panel.scale = Vector2(1.0, 1.0)
	
	print("Dialog panel visible: ", dialog_panel.visible)
	print("Dialog panel modulate: ", dialog_panel.modulate)
	print("Dialog panel scale: ", dialog_panel.scale)
	
	# Skip animation for now to see if dialog appears
	print("Skipping animation for debugging")

func animate_dialog_out():
	"""Animate dialog disappearance"""
	if dialog_tween:
		dialog_tween.kill()
	
	dialog_tween = create_tween()
	dialog_tween.set_parallel(true)
	
	# Fade out background
	dialog_tween.tween_property(self, "modulate:a", 0.0, 0.2)
	
	# Scale and fade out dialog
	dialog_tween.tween_property(dialog_panel, "scale", Vector2(0.8, 0.8), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	dialog_tween.tween_property(dialog_panel, "modulate:a", 0.0, 0.2)
	
	await dialog_tween.finished
	hide()

func _on_resume_button_pressed():
	"""Resume from last lesson"""
	print("Resume button pressed!")
	animate_dialog_out()
	await dialog_tween.finished  # Wait for animation to complete
	resume_selected.emit(resume_info.lesson_type, resume_info.lesson_number)

func _on_start_fresh_button_pressed():
	"""Start from lesson 1"""
	print("Start fresh button pressed!")
	animate_dialog_out()
	await dialog_tween.finished  # Wait for animation to complete
	start_fresh_selected.emit(current_lesson_type)

func _on_cancel_button_pressed():
	"""Cancel and close dialog"""
	print("Cancel button pressed!")
	animate_dialog_out()
	await dialog_tween.finished  # Wait for animation to complete
	dialog_closed.emit()

func _on_dialog_finished():
	"""Called when dialog animation finishes"""
	dialog_closed.emit()
