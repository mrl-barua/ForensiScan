extends Node

var questions = []
var current_set = []
var current_index = 0

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
	current_index += 1
	if current_index < current_set.size():
		return true
	return false
