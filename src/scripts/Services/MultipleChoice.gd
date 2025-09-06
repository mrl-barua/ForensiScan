extends Control

# Enhanced Multiple Choice Component
# Modern UI/UX with animations and improved feedback

# Exported variables for customization
@export var question_text = "What is the answer?"
@export var option_a = "Option A"
@export var option_b = "Option B"
@export var option_c = "Option C"
@export var option_d = "Option D"
@export var question_number = "1"
@export var total_questions = "10"
@export var time_limit = 30.0
@export var correct_answer = "A"

# Signals
signal answer_selected(option, letter)
signal time_expired
signal animation_completed

# Node references
@onready var question: RichTextLabel = $MainContainer/QuestionSection/QuestionPanel/QuestionContent/Question
@onready var question_title: Label = $MainContainer/QuestionSection/QuestionHeader/QuestionTitle
@onready var question_number_label: Label = $MainContainer/QuestionSection/QuestionHeader/QuestionNumber
@onready var timer_label: Label = $MainContainer/OptionsSection/OptionsHeader/Timer
@onready var status_label: Label = $MainContainer/StatusSection/StatusLabel

@onready var option_a_btn: Button = $MainContainer/OptionsSection/OptionsPanel/OptionsContent/OptionsGrid/OptionA
@onready var option_b_btn: Button = $MainContainer/OptionsSection/OptionsPanel/OptionsContent/OptionsGrid/OptionB
@onready var option_c_btn: Button = $MainContainer/OptionsSection/OptionsPanel/OptionsContent/OptionsGrid/OptionC
@onready var option_d_btn: Button = $MainContainer/OptionsSection/OptionsPanel/OptionsContent/OptionsGrid/OptionD

@onready var main_container: VBoxContainer = $MainContainer
@onready var question_panel: Panel = $MainContainer/QuestionSection/QuestionPanel
@onready var options_panel: Panel = $MainContainer/OptionsSection/OptionsPanel

# Animation and state management
var entrance_tween: Tween
var button_tweens: Dictionary = {}
var timer_tween: Tween
var time_remaining: float
var selected_option: String = ""
var is_answered: bool = false
var buttons_array: Array[Button] = []

func _ready():
	setup_ui()
	setup_animations()
	update_display()
	start_timer()

func setup_ui():
	"""Initialize UI components and collect button references"""
	buttons_array = [option_a_btn, option_b_btn, option_c_btn, option_d_btn]
	setup_button_connections()
	
	# Set initial state for entrance animation
	main_container.modulate.a = 0.0
	main_container.scale = Vector2(0.9, 0.9)

func setup_button_connections():
	"""Connect hover effects for all option buttons"""
	for button in buttons_array:
		if not button.mouse_entered.is_connected(_on_button_hover):
			button.mouse_entered.connect(_on_button_hover.bind(button))
		if not button.mouse_exited.is_connected(_on_button_unhover):
			button.mouse_exited.connect(_on_button_unhover.bind(button))

func setup_animations():
	"""Setup entrance animations for the component"""
	if entrance_tween:
		entrance_tween.kill()
	
	entrance_tween = create_tween()
	entrance_tween.set_parallel(true)
	
	# Fade in and scale up main container
	entrance_tween.tween_property(main_container, "modulate:a", 1.0, 0.6)
	entrance_tween.tween_property(main_container, "scale", Vector2(1.0, 1.0), 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Animate question panel
	question_panel.position.y = -50
	entrance_tween.tween_property(question_panel, "position:y", 0, 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.2)
	
	# Animate options with staggered timing
	for i in range(buttons_array.size()):
		var button = buttons_array[i]
		button.modulate.a = 0.0
		button.scale = Vector2(0.8, 0.8)
		var delay = 0.4 + (i * 0.1)
		
		entrance_tween.tween_property(button, "modulate:a", 1.0, 0.4).set_delay(delay)
		entrance_tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(delay)
	
	entrance_tween.tween_callback(func(): animation_completed.emit()).set_delay(1.2)

func update_display():
	"""Update all display elements with current data"""
	if question:
		question.text = "[center]" + question_text + "[/center]"
	
	if question_number_label:
		question_number_label.text = question_number + "/" + total_questions
	
	if option_a_btn:
		option_a_btn.text = "A. " + option_a
	if option_b_btn:
		option_b_btn.text = "B. " + option_b
	if option_c_btn:
		option_c_btn.text = "C. " + option_c
	if option_d_btn:
		option_d_btn.text = "D. " + option_d
	
	time_remaining = time_limit
	update_timer_display()

func start_timer():
	"""Start the question timer"""
	if timer_tween:
		timer_tween.kill()
	
	timer_tween = create_tween()
	timer_tween.tween_method(update_timer, time_limit, 0.0, time_limit)
	timer_tween.tween_callback(func(): 
		if not is_answered:
			_on_time_expired()
	)

func update_timer(time_left: float):
	"""Update timer display"""
	time_remaining = time_left
	update_timer_display()

func update_timer_display():
	"""Update the visual timer display"""
	var minutes = int(time_remaining) / 60
	var seconds = int(time_remaining) % 60
	timer_label.text = "⏱️ %02d:%02d" % [minutes, seconds]
	
	# Change color as time runs out
	if time_remaining <= 10:
		timer_label.modulate = Color(1.0, 0.4, 0.4, 1.0)  # Red
	elif time_remaining <= 20:
		timer_label.modulate = Color(1.0, 0.8, 0.4, 1.0)  # Orange
	else:
		timer_label.modulate = Color(1.0, 0.8, 0.4, 1.0)  # Normal

func _on_button_hover(button: Button):
	"""Enhanced button hover effect"""
	if is_answered:
		return
	
	var button_id = button.get_instance_id()
	if button_tweens.has(button_id):
		button_tweens[button_id].kill()
	
	button_tweens[button_id] = create_tween()
	var tween = button_tweens[button_id]
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1.03, 1.03), 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property(button, "rotation", deg_to_rad(0.5), 0.2).set_trans(Tween.TRANS_SINE)

func _on_button_unhover(button: Button):
	"""Enhanced button unhover effect"""
	if is_answered:
		return
	
	var button_id = button.get_instance_id()
	if button_tweens.has(button_id):
		button_tweens[button_id].kill()
	
	button_tweens[button_id] = create_tween()
	var tween = button_tweens[button_id]
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property(button, "rotation", 0.0, 0.2).set_trans(Tween.TRANS_SINE)
	
	tween.finished.connect(func(): 
		if button_tweens.has(button_id):
			button_tweens.erase(button_id)
	)

func handle_answer_selection(option: String, letter: String, button: Button):
	"""Handle answer selection with visual feedback"""
	if is_answered:
		return
	
	is_answered = true
	selected_option = letter
	
	# Stop timer
	if timer_tween:
		timer_tween.kill()
	
	# Disable all buttons and show selection feedback
	for btn in buttons_array:
		btn.disabled = true
		if btn != button:
			btn.modulate = Color(0.6, 0.6, 0.6, 0.8)  # Dim unselected options
	
	# Animate selected button
	var selection_tween = create_tween()
	selection_tween.set_parallel(true)
	selection_tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.3).set_trans(Tween.TRANS_BACK)
	
	# Update status
	status_label.text = "✅ Answer selected: " + letter + ". " + option
	status_label.modulate = Color(0.4, 1.0, 0.6, 1.0)
	
	# Emit signal with delay for visual feedback using a timer
	await get_tree().create_timer(0.5).timeout
	answer_selected.emit(option, letter)

func _on_time_expired():
	"""Handle timer expiration"""
	is_answered = true
	
	# Disable all buttons
	for btn in buttons_array:
		btn.disabled = true
		btn.modulate = Color(0.6, 0.6, 0.6, 0.8)
	
	# Update status
	status_label.text = "⏰ Time expired! No answer selected."
	status_label.modulate = Color(1.0, 0.6, 0.4, 1.0)
	timer_label.text = "⏱️ 00:00"
	timer_label.modulate = Color(1.0, 0.4, 0.4, 1.0)
	
	time_expired.emit()

# Button press handlers
func _on_option_a_pressed():
	handle_answer_selection(option_a, "A", option_a_btn)

func _on_option_b_pressed():
	handle_answer_selection(option_b, "B", option_b_btn)

func _on_option_c_pressed():
	handle_answer_selection(option_c, "C", option_c_btn)

func _on_option_d_pressed():
	handle_answer_selection(option_d, "D", option_d_btn)

# Public functions for external control
func reset_quiz():
	"""Reset the quiz component for a new question"""
	is_answered = false
	selected_option = ""
	
	# Re-enable and reset all buttons
	for btn in buttons_array:
		btn.disabled = false
		btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
		btn.scale = Vector2(1.0, 1.0)
		btn.rotation = 0.0
	
	# Reset status
	status_label.text = "💡 Select the best answer from the options above"
	status_label.modulate = Color(0.6, 0.7, 0.8, 1.0)
	
	# Restart timer
	time_remaining = time_limit
	start_timer()

func set_question_data(q_text: String, opts: Array, q_num: String, total: String, time_limit_sec: float = 30.0):
	"""Set question data programmatically"""
	question_text = q_text
	if opts.size() >= 4:
		option_a = opts[0]
		option_b = opts[1]
		option_c = opts[2]
		option_d = opts[3]
	
	question_number = q_num
	total_questions = total
	time_limit = time_limit_sec
	
	update_display()
	reset_quiz() 
