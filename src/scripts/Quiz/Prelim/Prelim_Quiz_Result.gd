extends Node2D

@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var history_label: RichTextLabel = $HistoryText
@onready var license_name: Label = $VBoxContainer/Name
@onready var license_semester: Label = $VBoxContainer/Semester
@onready var license_registered_device: Label = $VBoxContainer/DeviceId

func _ready():
	save_performance()
	score_label.text = "Your Score: %d/10" % QuizManager.get_score()
	var answers = QuizManager.get_answer_history()
	var history_text = ""
	for entry in answers:
		history_text += "Question: %s\n" % entry["question"]
		history_text += "Your Answer: %s\n" % entry["selected"]
		history_text += "Correct Answer: %s\n\n" % entry["correct"]
	history_label.text = history_text
	var details = LicenseProcessor.get_license_details()
	
	if details.size() > 0:
		license_name.text = "Name: " + str(details.get("name", "Unknown"))
		license_semester.text = "Semester: " + str(details.get("semester", "N/A"))
		license_registered_device.text = "Device ID: " + str(details.get("device_id", "Not Registered"))
	else:
		license_name.text = "❌ No license found"
		license_semester.text = ""
		license_registered_device.text = ""

func save_performance():
	var cfg = ConfigFile.new()
	cfg.set_value("performance", "score", QuizManager.get_score())
	cfg.set_value("performance", "answers", QuizManager.get_answer_history())
	cfg.save("user://prelim_performance.cfg")
