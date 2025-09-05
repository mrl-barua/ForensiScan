extends Node2D

@onready var multiple_choice = $MultipleChoice

func _ready():
	print("Quiz: Starting Prelim Quiz 1.1")
	print("Quiz: MultipleChoice node = ", multiple_choice)
	print("Quiz: MultipleChoice visible = ", multiple_choice.visible)
	print("Quiz: MultipleChoice size = ", multiple_choice.size)
	print("Quiz: MultipleChoice position = ", multiple_choice.position)
	
	# Ensure MultipleChoice is visible and properly positioned
	multiple_choice.visible = true
	multiple_choice.z_index = 10  # Ensure it's on top
	
	QuizManager.load_questions("Prelim")
	print("Quiz: Questions loaded, connecting signal")
	multiple_choice.answer_selected.connect(_on_MultipleChoice_answer_selected)
	
	# Small delay to ensure everything is ready
	await get_tree().process_frame
	show_question()

func show_question():
	print("Quiz: Showing current question")
	var q = QuizManager.get_current_question()
	if q == null:
		print("ERROR: No question available!")
		return
		
	print("Quiz: Question text = ", q.get("text", "NO TEXT"))
	multiple_choice.question_text = q.get("text", "Question not found")
	multiple_choice.option_a = "A. " + q.get("options", ["", "", "", ""])[0]
	multiple_choice.option_b = "B. " + q.get("options", ["", "", "", ""])[1]
	multiple_choice.option_c = "C. " + q.get("options", ["", "", "", ""])[2]
	multiple_choice.option_d = "D. " + q.get("options", ["", "", "", ""])[3]
	multiple_choice.update_display()
	print("Quiz: Display updated")

func _on_MultipleChoice_answer_selected(option):
	print("Quiz: Answer selected Question 1:", option)
	QuizManager.submit_answer(option)
	if QuizManager.next_question():
		get_tree().change_scene_to_file("res://src/scenes/Quiz/Prelim/Prelim_Quiz_1.2.tscn")
	else:
		print("Quiz: No more questions, quiz completed")
		# Handle quiz completion
		get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn")

func has_taken_prelim() -> bool:
	return FileAccess.file_exists("user://prelim_performance.cfg")
