extends Node2D

@onready var multiple_choice = $MultipleChoice

func _ready():
	QuizManager.load_questions("Prelim")
	multiple_choice.connect("answer_selected", Callable(self, "_on_MultipleChoice_answer_selected"))
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
	print("Answer selected Question 1:", option)
	QuizManager.submit_answer(option)
	if QuizManager.next_question():
		get_tree().change_scene_to_file("res://src/scenes/Quiz/Prelim/Prelim_Quiz_1.2.tscn")
		
func has_taken_prelim() -> bool:
	return FileAccess.file_exists("user://prelim_performance.cfg")
	if has_taken_prelim():
		get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn")
