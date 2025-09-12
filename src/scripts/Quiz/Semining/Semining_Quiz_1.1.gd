extends Node2D

# Semining Quiz 1.2 - Results and Continuation Screen
# Professional completion screen with navigation options

# UI Node references
@onready var header_label: Label = $Header
@onready var sub_header_label: Label = $SubHeader
@onready var main_panel: Panel = $MainPanel
@onready var completion_message: Label = $MainPanel/CompletionMessage
@onready var progress_label: Label = $ProgressIndicator/ProgressLabel

# Animation and state variables
var entrance_tween: Tween
var has_animated: bool = false

func _ready():
	print("🎉 Semining Quiz 1.2 Results Screen initialized")
	setup_simplified_content()
	setup_entrance_animation()
	
	# Auto-redirect to results after showing completion message
	setup_auto_redirect()

func setup_simplified_content():	
	# Set complete text content (not appending to avoid duplication)
	if completion_message:
		completion_message.text = """
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
	
	# Start entrance sequence
	await get_tree().create_timer(0.3).timeout
	animate_entrance()

func setup_auto_redirect():
	"""Setup automatic redirect to results screen"""
	# Wait for entrance animation to complete, then redirect
	await get_tree().create_timer(8.0).timeout  # Show content for 4 seconds
	
	print("🔄 Auto-redirecting to detailed results...")
	get_tree().change_scene_to_file("res://src/scenes/Quiz/Semining/Semining_Quiz_1.2.tscn")

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
	
	# Progress indicator
	entrance_tween.tween_property(progress_label, "modulate:a", 1.0, 0.5).set_delay(1.5)
	
	# Set initial panel scale for animation
	main_panel.scale = Vector2(0.9, 0.9)

# Legacy button handler functions (removed for auto-redirect)
# Buttons removed - auto-redirecting to results screen

func update_progress_display(score: int = -1, total_questions: int = 10):
	"""Update progress display with quiz results"""
	if progress_label:
		var progress_text = "📈 Progress: Semining Part 1 Complete"
		
		if score >= 0:
			var percentage = (score / float(total_questions)) * 100
			progress_text += " | Score: %d/%d (%.0f%%)" % [score, total_questions, percentage]
		
		progress_text += " | Next: Advanced Classification Analysis | Overall: 50% Complete"
		progress_label.text = progress_text
