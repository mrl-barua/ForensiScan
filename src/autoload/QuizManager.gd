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

# File paths for persistent storage
const QUIZ_RESULTS_FILE = "user://quiz_results.save"
const LATEST_SCORE_FILE = "user://latest_score.save"

func _ready():
	"""Initialize QuizManager and load persistent data"""
	print("🔄 QuizManager initializing...")
	load_persistent_data()
	print("✅ QuizManager ready with persistent data loaded")

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
	"""Store quiz results for later retrieval across scenes with disk persistence"""
	# Calculate percentage based on the actual maximum possible score
	var max_possible_score = total_questions * 10  # Each question worth 10 points
	var percentage = (final_score / float(max_possible_score)) * 100.0
	
	var quiz_data = {
		"quiz_id": quiz_id,
		"score": final_score,
		"total_questions": total_questions,
		"percentage": percentage,
		"user_answers": answers,
		"correct_answers": correct_answers,
		"timestamp": Time.get_ticks_msec(),
		"completed": true
	}
	
	# Store as latest score
	latest_score_data = quiz_data
	
	# Store in results storage
	quiz_results_storage[quiz_id] = quiz_data
	
	# Save to disk for persistence
	save_persistent_data()
	
	print("📊 QuizManager: Results stored for ", quiz_id)
	print("  Score: ", final_score, "/", max_possible_score)
	print("  Percentage: ", percentage, "%")
	print("  Quiz Type: ", determine_quiz_type_from_id(quiz_id))
	print("  Formatted Name: ", format_quiz_name(quiz_id))
	print("💾 Data saved to disk for persistence")
	
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
	
	# Also clear persistent data
	save_persistent_data()
	
	print("🗑️ QuizManager: All quiz data cleared (including persistent data)")

func save_persistent_data():
	"""Save quiz results and latest score to disk"""
	var save_file = FileAccess.open(QUIZ_RESULTS_FILE, FileAccess.WRITE)
	if save_file:
		var save_data = {
			"quiz_results_storage": quiz_results_storage,
			"save_timestamp": Time.get_ticks_msec()
		}
		save_file.store_string(JSON.stringify(save_data))
		save_file.close()
		print("💾 Quiz results saved to disk")
	else:
		print("❌ Failed to save quiz results to disk")
	
	var latest_file = FileAccess.open(LATEST_SCORE_FILE, FileAccess.WRITE)
	if latest_file:
		var latest_data = {
			"latest_score_data": latest_score_data,
			"save_timestamp": Time.get_ticks_msec()
		}
		latest_file.store_string(JSON.stringify(latest_data))
		latest_file.close()
		print("💾 Latest score saved to disk")
	else:
		print("❌ Failed to save latest score to disk")

func load_persistent_data():
	"""Load quiz results and latest score from disk"""
	print("📂 Loading persistent quiz data...")
	
	# Load quiz results storage
	if FileAccess.file_exists(QUIZ_RESULTS_FILE):
		var load_file = FileAccess.open(QUIZ_RESULTS_FILE, FileAccess.READ)
		if load_file:
			var json_text = load_file.get_as_text()
			load_file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_text)
			
			if parse_result == OK:
				var save_data = json.data
				quiz_results_storage = save_data.get("quiz_results_storage", {})
				print("✅ Loaded ", quiz_results_storage.size(), " quiz results from disk")
			else:
				print("⚠️ Failed to parse quiz results file")
		else:
			print("⚠️ Failed to open quiz results file")
	else:
		print("📝 No existing quiz results file found, starting fresh")
	
	# Load latest score data
	if FileAccess.file_exists(LATEST_SCORE_FILE):
		var latest_file = FileAccess.open(LATEST_SCORE_FILE, FileAccess.READ)
		if latest_file:
			var json_text = latest_file.get_as_text()
			latest_file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_text)
			
			if parse_result == OK:
				var latest_data = json.data
				latest_score_data = latest_data.get("latest_score_data", {})
				print("✅ Loaded latest score data from disk")
			else:
				print("⚠️ Failed to parse latest score file")
		else:
			print("⚠️ Failed to open latest score file")
	else:
		print("📝 No existing latest score file found")
	
	print("📊 Persistent data loaded - ", quiz_results_storage.size(), " total quiz results available")

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
	print("  Persistent Files:")
	print("    Quiz Results File Exists: ", FileAccess.file_exists(QUIZ_RESULTS_FILE))
	print("    Latest Score File Exists: ", FileAccess.file_exists(LATEST_SCORE_FILE))
	
	# Verify persistent data integrity
	if FileAccess.file_exists(QUIZ_RESULTS_FILE):
		var size = FileAccess.get_file_as_bytes(QUIZ_RESULTS_FILE).size()
		print("    Quiz Results File Size: ", size, " bytes")
	
	if FileAccess.file_exists(LATEST_SCORE_FILE):
		var size = FileAccess.get_file_as_bytes(LATEST_SCORE_FILE).size()
		print("    Latest Score File Size: ", size, " bytes")

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

func get_all_results() -> Array:
	"""Get all quiz results formatted for the results dashboard"""
	var all_results = []
	
	for quiz_id in quiz_results_storage.keys():
		var quiz_data = quiz_results_storage[quiz_id]
		if quiz_data.get("completed", false):
			var result = {
				"quiz_name": format_quiz_name(quiz_id),
				"quiz_type": determine_quiz_type_from_id(quiz_id),
				"score": quiz_data.get("score", 0),
				"percentage": quiz_data.get("percentage", 0.0),
				"grade": get_letter_grade(quiz_data.get("percentage", 0.0)),
				"total_questions": quiz_data.get("total_questions", 0),
				"correct_answers": quiz_data.get("score", 0) / 10,  # Calculate actual correct answers
				"timestamp": format_timestamp(quiz_data.get("timestamp", 0))
			}
			all_results.append(result)
	
	return all_results

func format_quiz_name(quiz_id: String) -> String:
	"""Format quiz ID into a readable name"""
	match quiz_id:
		"Prelim_Quiz_Complete":
			return "Prelim Quiz 1.1"
		"Midterm_Quiz_1.1":
			return "Midterm Quiz 1.1"
		"Semining_Quiz_1.1":
			return "Semining Quiz 1.1"
		"Semining_Quiz_1.2":
			return "Semining Quiz 1.2"
		_:
			return quiz_id.replace("_", " ")

func determine_quiz_type_from_id(quiz_id: String) -> String:
	"""Determine quiz type from quiz ID"""
	if "Prelim" in quiz_id or "prelim" in quiz_id:
		return "prelim"
	elif "Midterm" in quiz_id or "midterm" in quiz_id:
		return "midterm"
	elif "Semining" in quiz_id or "semining" in quiz_id:
		return "semining"
	else:
		return "unknown"

func format_timestamp(timestamp_ms: int) -> String:
	"""Format timestamp for display"""
	if timestamp_ms == 0:
		return "Unknown"
	
	var datetime = Time.get_datetime_dict_from_unix_time(timestamp_ms / 1000)
	return "%04d-%02d-%02d %02d:%02d" % [datetime.year, datetime.month, datetime.day, datetime.hour, datetime.minute]

func clear_all_results():
	"""Clear all stored quiz results"""
	clear_quiz_data()

func force_save_test_data():
	"""Force save some test data for debugging persistence"""
	print("🧪 Creating test data for persistence testing...")
	
	# Create test Prelim result
	store_quiz_results("Prelim_Quiz_Complete", 80, 10, [
		{"question": "Test Question 1", "selected": "Test Answer 1", "correct": "Test Answer 1"},
		{"question": "Test Question 2", "selected": "Wrong Answer", "correct": "Correct Answer"}
	], [])
	
	# Create test Midterm result
	store_quiz_results("Midterm_Quiz_1.1", 90, 10, [
		{"question": "Midterm Question 1", "selected": "Midterm Answer 1", "correct": "Midterm Answer 1"},
		{"question": "Midterm Question 2", "selected": "Midterm Answer 2", "correct": "Midterm Answer 2"}
	], [])
	
	print("✅ Test data created and saved to disk!")
	print_debug_info()
