extends Node

# Progress Manager Singleton
# Tracks lesson progress and provides resume functionality

signal progress_updated(lesson_type: String, lesson_number: int)

const SAVE_FILE = "user://progress_data.json"

# Progress data structure
var progress_data = {
	"prelim": {
		"current_lesson": 1,
		"max_lesson": 25,
		"last_accessed": "",
		"completed_lessons": []
	},
	"midterm": {
		"current_lesson": 1,
		"max_lesson": 65,
		"last_accessed": "",
		"completed_lessons": []
	}
}

func _ready():
	load_progress()

func update_lesson_progress(lesson_type: String, lesson_number: int):
	"""Update progress for a specific lesson"""
	print("=== update_lesson_progress called ===")
	print("Lesson type: ", lesson_type)
	print("Lesson number: ", lesson_number)
	print("Current progress_data before update: ", progress_data)
	
	if not progress_data.has(lesson_type):
		print("ERROR: Invalid lesson type: ", lesson_type)
		return
	
	var lesson_data = progress_data[lesson_type]
	print("Current lesson_data before update: ", lesson_data)
	
	# Update current lesson if this is further than before
	if lesson_number > lesson_data.current_lesson:
		lesson_data.current_lesson = lesson_number
		print("Updated current_lesson to: ", lesson_number)
	
	# Add to completed lessons if not already there
	if lesson_number not in lesson_data.completed_lessons:
		lesson_data.completed_lessons.append(lesson_number)
		lesson_data.completed_lessons.sort()
		print("Added lesson to completed: ", lesson_number)
	
	# Update timestamp
	lesson_data.last_accessed = Time.get_datetime_string_from_system()
	print("Updated timestamp: ", lesson_data.last_accessed)
	
	# Save progress
	save_progress()
	
	# Emit signal
	progress_updated.emit(lesson_type, lesson_number)
	
	print("Final progress_data: ", progress_data)
	print("Progress updated: %s lesson %d" % [lesson_type, lesson_number])

func has_progress() -> bool:
	"""Check if user has any meaningful progress"""
	for lesson_type in progress_data.keys():
		var lesson_data = progress_data[lesson_type]
		if lesson_data.current_lesson > 1 or lesson_data.completed_lessons.size() > 0:
			return true
	return false

func get_resume_info() -> Dictionary:
	"""Get information about the most recent progress"""
	var most_recent_type = ""
	var most_recent_time = ""
	var most_recent_lesson = 1
	
	for lesson_type in progress_data.keys():
		var lesson_data = progress_data[lesson_type]
		if lesson_data.last_accessed != "" and (most_recent_time == "" or lesson_data.last_accessed > most_recent_time):
			most_recent_type = lesson_type
			most_recent_time = lesson_data.last_accessed
			most_recent_lesson = lesson_data.current_lesson
	
	if most_recent_type == "":
		return {}
	
	return {
		"lesson_type": most_recent_type,
		"lesson_number": most_recent_lesson,
		"total_lessons": progress_data[most_recent_type].max_lesson,
		"timestamp": most_recent_time,
		"completed_lessons": progress_data[most_recent_type].completed_lessons.duplicate()
	}

func get_lesson_scene_path(lesson_type: String, lesson_number: int) -> String:
	"""Generate the scene path for a specific lesson"""
	var lesson_type_cap = lesson_type.capitalize()
	return "res://src/scenes/Lesson/%s/%s_%d.%d.tscn" % [lesson_type_cap, lesson_type_cap, 1, lesson_number]

func reset_to_lesson(lesson_type: String, lesson_number: int):
	"""Reset progress to a specific lesson"""
	if not progress_data.has(lesson_type):
		print("Invalid lesson type: ", lesson_type)
		return
	
	var lesson_data = progress_data[lesson_type]
	lesson_data.current_lesson = lesson_number
	lesson_data.last_accessed = Time.get_datetime_string_from_system()
	
	# Remove completed lessons after the reset point
	lesson_data.completed_lessons = lesson_data.completed_lessons.filter(func(x): return x < lesson_number)
	
	save_progress()
	print("Progress reset: %s to lesson %d" % [lesson_type, lesson_number])

func get_progress_for_type(lesson_type: String) -> Dictionary:
	"""Get progress data for a specific lesson type"""
	if progress_data.has(lesson_type):
		return progress_data[lesson_type].duplicate()
	return {}

func clear_all_progress():
	"""Clear all progress data"""
	for lesson_type in progress_data.keys():
		progress_data[lesson_type].current_lesson = 1
		progress_data[lesson_type].last_accessed = ""
		progress_data[lesson_type].completed_lessons.clear()
	save_progress()
	print("All progress cleared")

func save_progress():
	"""Save progress data to file"""
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(progress_data)
		file.store_string(json_string)
		file.close()
		print("Progress saved to: ", SAVE_FILE)
	else:
		print("Failed to save progress data")

func load_progress():
	"""Load progress data from file"""
	print("=== load_progress called ===")
	if not FileAccess.file_exists(SAVE_FILE):
		print("No save file found at: ", SAVE_FILE)
		print("Using default progress")
		return
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		print("Loaded JSON string: ", json_string)
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var loaded_data = json.data
			print("Parsed data: ", loaded_data)
			if typeof(loaded_data) == TYPE_DICTIONARY:
				# Merge loaded data with default structure to ensure all fields exist
				for lesson_type in progress_data.keys():
					if loaded_data.has(lesson_type):
						progress_data[lesson_type].merge(loaded_data[lesson_type])
				print("Progress loaded successfully. Final data: ", progress_data)
			else:
				print("Invalid save data format")
		else:
			print("Failed to parse save file")
	else:
		print("Failed to load progress data")

func _notification(what):
	"""Handle application events"""
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_progress()
