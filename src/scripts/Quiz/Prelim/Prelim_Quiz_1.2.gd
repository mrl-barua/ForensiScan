extends Node2D

@onready var multiple_choice = $MultipleChoice

func _ready():
	show_question()

func show_question():
	var q = QuizManager.get_current_question()
	multiple_choice.question_text = q["text"]
	multiple_choice.option_a = q["options"][0]
	multiple_choice.option_b = q["options"][1]
	multiple_choice.option_c = q["options"][2]
	multiple_choice.option_d = q["options"][3]
	multiple_choice.update_display()

func _on_MultipleChoice_answer_selected(option):
	if QuizManager.next_question():
		show_question()
	else:
		get_tree().change_scene("res://src/scenes/Quiz/Prelim/Prelim_Quiz_1.3.tscn")
