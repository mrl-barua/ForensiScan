extends Node

# Original quiz functionality
var questions = []
var current_set = []
var current_index = 0
var user_answers = []
var score = 0

# Enhanced persistence functionality
var quiz_results_storage: Dictionary = {}
var latest_score_data: Dictionary = {}
var session_active: bool = false

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

func create_test_data():
	"""Create sample quiz data for testing"""
	print("QuizManager: Creating test data...")
	
	# Create sample questions and answers
	current_set = [
		{"text": "What is a fingerprint?", "answer": "A unique pattern"},
		{"text": "How many ridge patterns exist?", "answer": "Three main types"},
		{"text": "What is forensic science?", "answer": "Science applied to law"}
	]
	
	# Create sample user answers  
	user_answers = [
		{"question": "What is a fingerprint?", "selected": "A unique pattern", "correct": "A unique pattern"},
		{"question": "How many ridge patterns exist?", "selected": "Five types", "correct": "Three main types"},
		{"question": "What is forensic science?", "selected": "Science applied to law", "correct": "Science applied to law"}
	]
	
	score = 2  # 2 out of 3 correct
	current_index = 3  # Quiz completed
	
	print("QuizManager: Test data created - Score: ", score, "/", current_set.size())

# Enhanced persistence functions
func store_quiz_results(quiz_id: String, final_score: int, total_questions: int, answers: Array = [], correct_answers: Array = []):
	"""Store quiz results for later retrieval across scenes"""
	var quiz_data = {
		"quiz_id": quiz_id,
		"score": final_score,
		"total_questions": total_questions,
		"percentage": (final_score / float(total_questions * 10)) * 100.0,
		"user_answers": answers,
		"correct_answers": correct_answers,
		"timestamp": Time.get_ticks_msec(),
		"completed": true
	}
	
	# Store as latest score
	latest_score_data = quiz_data
	
	# Store in results storage
	quiz_results_storage[quiz_id] = quiz_data
	
	print("📊 QuizManager: Results stored for ", quiz_id)
	print("  Score: ", final_score, "/", total_questions * 10)
	print("  Percentage: ", quiz_data.percentage, "%")
	
	return quiz_data

func get_latest_score() -> Dictionary:
	"""Get the most recent quiz score data"""
	return latest_score_data

func get_quiz_results(quiz_id: String) -> Dictionary:
	"""Get specific quiz results by ID"""
	return quiz_results_storage.get(quiz_id, {})

func is_quiz_completed(quiz_id: String) -> bool:
	"""Check if a specific quiz has been completed"""
	var quiz_data = quiz_results_storage.get(quiz_id, {})
	return quiz_data.get("completed", false)

func clear_quiz_data():
	"""Clear all stored quiz data"""
	quiz_results_storage.clear()
	latest_score_data.clear()
	session_active = false
	print("🗑️ QuizManager: All quiz data cleared")

func get_letter_grade(percentage: float) -> String:
	"""Convert percentage to letter grade"""
	if percentage >= 97: return "A+"
	elif percentage >= 93: return "A"
	elif percentage >= 90: return "A-"
	elif percentage >= 87: return "B+"
	elif percentage >= 83: return "B"
	elif percentage >= 80: return "B-"
	elif percentage >= 77: return "C+"
	elif percentage >= 73: return "C"
	elif percentage >= 70: return "C-"
	elif percentage >= 67: return "D+"
	elif percentage >= 65: return "D"
	else: return "F"

func print_debug_info():
	"""Print current status for debugging"""
	print("📋 QuizManager Debug Info:")
	print("  Session Active: ", session_active)
	print("  Latest Score: ", latest_score_data)
	print("  Stored Quizzes: ", quiz_results_storage.keys())

func get_prelim_results() -> Dictionary:
	"""Get specifically the Prelim quiz results"""
	return get_quiz_results("Prelim_Quiz_Complete")

func get_midterm_results() -> Dictionary:
	"""Get specifically the Midterm quiz results"""
	return get_quiz_results("Midterm_Quiz_1.1")

func has_completed_quiz(quiz_id: String) -> bool:
	"""Check if a specific quiz has been completed and has valid results"""
	var results = get_quiz_results(quiz_id)
	return results.has("completed") and results.get("completed", false)

func get_all_completed_quizzes() -> Array[String]:
	"""Get list of all completed quiz IDs"""
	var completed = []
	for quiz_id in quiz_results_storage.keys():
		if has_completed_quiz(quiz_id):
			completed.append(quiz_id)
	return completed
