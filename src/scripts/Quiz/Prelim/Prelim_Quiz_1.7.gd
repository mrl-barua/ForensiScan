extends Node2D

@onready var multiple_choice = $MultipleChoice

func _ready():
	multiple_choice.answer_selected.connect(_on_MultipleChoice_answer_selected)
	multiple_choice.time_expired.connect(_on_MultipleChoice_time_expired)
	show_question()

func show_question():
	var q = QuizManager.get_current_question()
	multiple_choice.question_text = q["text"]
	multiple_choice.option_a = q["options"][0]
	multiple_choice.option_b = q["options"][1]
	multiple_choice.option_c = q["options"][2]
	multiple_choice.option_d = q["options"][3]
	
	# Set question number info
	var current_q_num = str(QuizManager.current_index + 1)
	var total_q_num = str(QuizManager.current_set.size())
	multiple_choice.question_number = current_q_num
	multiple_choice.total_questions = total_q_num
	
	multiple_choice.update_display()

func _on_MultipleChoice_answer_selected(option: String, letter: String):
	print("Answer selected Question 7 - Letter: ", letter, " Option: ", option)
	QuizManager.submit_answer(option)
	if QuizManager.next_question():
		get_tree().change_scene_to_file("res://src/scenes/Quiz/Prelim/Prelim_Quiz_1.8.tscn")

func _on_MultipleChoice_time_expired():
	print("Quiz: Time expired for question 7 - proceeding to next")
	QuizManager.submit_answer("")
	if QuizManager.next_question():
		get_tree().change_scene_to_file("res://src/scenes/Quiz/Prelim/Prelim_Quiz_1.8.tscn")
		
