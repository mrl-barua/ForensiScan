extends Node

var questions = []
var current_set = []
var current_index = 0
var user_answers = []
var score = 0

func load_questions(section: String):
	print("QuizManager: Loading questions for section: ", section)
	var file = FileAccess.open("res://assets/json/question.json", FileAccess.READ)
	if file == null:
		print("ERROR: Could not open question.json file!")
		return
		
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		print("ERROR: Could not parse JSON file!")
		return
		
	var data = json.data
	if not data.has(section):
		print("ERROR: Section '", section, "' not found in questions!")
		return
		
	questions = data[section]
	print("QuizManager: Loaded ", questions.size(), " questions")
	questions.shuffle() # randomize order
	current_set = questions.slice(0, min(10, questions.size())) # pick up to 10 random questions
	current_index = 0
	user_answers.clear()
	score = 0
	print("QuizManager: Quiz setup complete with ", current_set.size(), " questions")

func get_current_question():
	if current_index >= current_set.size():
		print("ERROR: No more questions available!")
		return null
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
