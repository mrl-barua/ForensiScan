extends Node

# ProgressManager - Singleton for tracking lesson progress
# Handles saving/loading user progress through lessons

signal progress_updated(lesson_type: String, lesson_number: int)
signal progress_cleared()

const SAVE_FILE_PATH = "user://lesson_progress.save"

# Progress data structure
var progress_data = {
	"prelim": {
		"current_lesson": 1,
		"max_reached": 1,
		"completed_lessons": [],
		"last_accessed": ""
	},
	"midterm": {
		"current_lesson": 1,
		"max_reached": 1, 
		"completed_lessons": [],
		"last_accessed": ""
	},
	"last_session": {
		"lesson_type": "",
		"lesson_number": 1,
		"timestamp": ""
	}
}

func _ready():
	load_progress()

# === PROGRESS TRACKING ===

func update_lesson_progress(lesson_type: String, lesson_number: int):
	"""Update progress when a lesson is accessed"""
	lesson_type = lesson_type.to_lower()
	
	if not progress_data.has(lesson_type):
		print("ProgressManager: Invalid lesson type: ", lesson_type)
		return
	
	var type_data = progress_data[lesson_type]
	
	# Update current lesson
	type_data.current_lesson = lesson_number
	
	# Update max reached (highest lesson accessed)
	if lesson_number > type_data.max_reached:
		type_data.max_reached = lesson_number
	
	# Update last accessed timestamp
	type_data.last_accessed = Time.get_datetime_string_from_system()
	
	# Update global last session
	progress_data.last_session = {
		"lesson_type": lesson_type,
		"lesson_number": lesson_number,
		"timestamp": Time.get_datetime_string_from_system()
	}
	
	save_progress()
	progress_updated.emit(lesson_type, lesson_number)
	
	print("ProgressManager: Updated progress - %s lesson %d" % [lesson_type, lesson_number])

func mark_lesson_completed(lesson_type: String, lesson_number: int):
	"""Mark a specific lesson as completed"""
	lesson_type = lesson_type.to_lower()
	
	if not progress_data.has(lesson_type):
		return
	
	var type_data = progress_data[lesson_type]
	
	if lesson_number not in type_data.completed_lessons:
		type_data.completed_lessons.append(lesson_number)
		type_data.completed_lessons.sort()
		save_progress()
		print("ProgressManager: Marked %s lesson %d as completed" % [lesson_type, lesson_number])

# === PROGRESS QUERIES ===

func has_progress() -> bool:
	"""Check if user has any saved progress"""
	var last_session = progress_data.last_session
	return last_session.lesson_type != "" and last_session.lesson_number > 1

func get_last_lesson() -> Dictionary:
	"""Get the last accessed lesson"""
	return progress_data.last_session.duplicate()

func get_progress_summary(lesson_type: String) -> Dictionary:
	"""Get progress summary for a lesson type"""
	lesson_type = lesson_type.to_lower()
	if progress_data.has(lesson_type):
		return progress_data[lesson_type].duplicate()
	return {}

func get_resume_info() -> Dictionary:
	"""Get information for resume functionality"""
	var last_session = progress_data.last_session
	if last_session.lesson_type == "":
		return {}
	
	var lesson_type = last_session.lesson_type
	var lesson_number = last_session.lesson_number
	var total_lessons = 25 if lesson_type == "prelim" else 65
	
	return {
		"lesson_type": lesson_type,
		"lesson_number": lesson_number,
		"total_lessons": total_lessons,
		"scene_path": get_lesson_scene_path(lesson_type, lesson_number),
		"display_name": "%s Lesson %d" % [lesson_type.capitalize(), lesson_number],
		"timestamp": last_session.timestamp
	}

func get_lesson_scene_path(lesson_type: String, lesson_number: int) -> String:
	"""Generate scene path for a lesson"""
	var type_folder = lesson_type.capitalize()
	return "res://src/scenes/Lesson/%s/%s_1.%d.tscn" % [type_folder, type_folder, lesson_number]

# === PROGRESS MANAGEMENT ===

func clear_progress(lesson_type: String = ""):
	"""Clear progress for a specific type or all progress"""
	if lesson_type == "":
		# Clear all progress
		progress_data = {
			"prelim": {
				"current_lesson": 1,
				"max_reached": 1,
				"completed_lessons": [],
				"last_accessed": ""
			},
			"midterm": {
				"current_lesson": 1,
				"max_reached": 1,
				"completed_lessons": [],
				"last_accessed": ""
			},
			"last_session": {
				"lesson_type": "",
				"lesson_number": 1,
				"timestamp": ""
			}
		}
		print("ProgressManager: Cleared all progress")
	else:
		# Clear specific lesson type
		lesson_type = lesson_type.to_lower()
		if progress_data.has(lesson_type):
			progress_data[lesson_type] = {
				"current_lesson": 1,
				"max_reached": 1,
				"completed_lessons": [],
				"last_accessed": ""
			}
			print("ProgressManager: Cleared %s progress" % lesson_type)
	
	save_progress()
	progress_cleared.emit()

func reset_to_lesson(lesson_type: String, lesson_number: int):
	"""Reset progress to a specific lesson"""
	lesson_type = lesson_type.to_lower()
	
	if not progress_data.has(lesson_type):
		return
	
	var type_data = progress_data[lesson_type]
	type_data.current_lesson = lesson_number
	type_data.last_accessed = Time.get_datetime_string_from_system()
	
	# Update last session
	progress_data.last_session = {
		"lesson_type": lesson_type,
		"lesson_number": lesson_number,
		"timestamp": Time.get_datetime_string_from_system()
	}
	
	save_progress()
	print("ProgressManager: Reset to %s lesson %d" % [lesson_type, lesson_number])

# === SAVE/LOAD ===

func save_progress():
	"""Save progress to file"""
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(progress_data))
		file.close()
		print("ProgressManager: Progress saved")
	else:
		print("ProgressManager: Failed to save progress")

func load_progress():
	"""Load progress from file"""
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("ProgressManager: No save file found, using defaults")
		return
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_text)
		
		if parse_result == OK:
			var loaded_data = json.data
			# Merge loaded data with defaults to ensure all fields exist
			merge_progress_data(loaded_data)
			print("ProgressManager: Progress loaded successfully")
		else:
			print("ProgressManager: Failed to parse save file")
	else:
		print("ProgressManager: Failed to open save file")

func merge_progress_data(loaded_data: Dictionary):
	"""Merge loaded data with default structure"""
	for key in loaded_data:
		if progress_data.has(key):
			if typeof(loaded_data[key]) == TYPE_DICTIONARY:
				for sub_key in loaded_data[key]:
					if progress_data[key].has(sub_key):
						progress_data[key][sub_key] = loaded_data[key][sub_key]
			else:
				progress_data[key] = loaded_data[key]

# === DEBUG FUNCTIONS ===

func print_progress():
	"""Debug function to print current progress"""
	print("=== PROGRESS MANAGER STATE ===")
	print("Prelim: Current=%d, Max=%d, Completed=%s" % [
		progress_data.prelim.current_lesson,
		progress_data.prelim.max_reached,
		str(progress_data.prelim.completed_lessons)
	])
	print("Midterm: Current=%d, Max=%d, Completed=%s" % [
		progress_data.midterm.current_lesson,
		progress_data.midterm.max_reached,
		str(progress_data.midterm.completed_lessons)
	])
	print("Last Session: %s lesson %d" % [
		progress_data.last_session.lesson_type,
		progress_data.last_session.lesson_number
	])
	print("===============================")
