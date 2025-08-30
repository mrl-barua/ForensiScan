extends Node

var questions = []
var current_set = []
var current_index = 0
var user_answers = []
var score = 0

func load_questions(section: String):
	var file = FileAccess.open("res://assets/json/question.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()

	questions = data[section]
	questions.shuffle() # randomize order
	current_set = questions.slice(0, 10) # pick 10 random questions
	current_index = 0

func get_current_question():
	return current_set[current_index]

func next_question():
	if current_index + 1 < current_set.size():
		current_index += 1
		return true
	return false
	
func submit_answer(selected_option):
	var current_question = get_current_question()
	user_answers.append({
		"question": current_question["text"],
		"selected": selected_option,
		"correct": current_question["answer"]
	})
	if selected_option == current_question["answer"]:
		score += 1
		
func get_score():
	return score

func get_answer_history():
	return user_answers
