extends Node2D

@export var header_text: String = "SECONDARY CLASSIFICATION"
@export var detail_one_text: String = "- POINTS TO REMEMBER!"
@export var detail_two_text: String = "- A. CAPITAL LETTER GROUP -it symbolized by capital letters of the patterns represented by the two index fingers after the primary classification in the classification line. -The fingerprint pattern appearing on the right index finger is the numerator while the fingerprint pattern from the left index Fingers is the Denominator."
@export var detail_three_text: String = ""
@export var detail_four_text: String = ""
@export var detail_five_text: String = ""
@export var detail_six_text: String = ""
@export var detail_seven_text: String = ""

@onready var header_label: RichTextLabel = $VBoxContainer/Header
@onready var detail_one_label: RichTextLabel = $VBoxContainer/DetailOne 
@onready var detail_two_label: RichTextLabel = $VBoxContainer/DetailTwo
@onready var detail_three_label: RichTextLabel = $VBoxContainer/DetailThree
@onready var detail_four_label: RichTextLabel = $VBoxContainer/DetailFour
@onready var detail_five_label: RichTextLabel = $VBoxContainer/DetailFive
@onready var detail_six_label: RichTextLabel = $VBoxContainer/DetailSix
@onready var detail_seven_label: RichTextLabel = $VBoxContainer/DetailSeven
var typewriter: Typewriter

@onready var navigation_buttons: Control = $NavigationControls

func _ready():
	# Track progress for this lesson
	ProgressManager.update_lesson_progress("midterm", 56)
	
	header_label.text = ''
	detail_one_label.text = ''
	detail_two_label.text = ''
	detail_three_label.text = ''
	detail_four_label.text = ''
	detail_five_label.text = ''
	detail_six_label.text = ''
	detail_seven_label.text = ''
	typewriter = Typewriter.new()
	add_child(typewriter)  
	
	typewriter.typing_finished.connect(_on_header_typing_done)
	typewriter.start_typing(header_label, header_text)

func _on_header_typing_done():
	print("Header typing finished!")
	typewriter.typing_finished.disconnect(_on_header_typing_done)
	typewriter.typing_finished.connect(_on_detail_one_typing_done)
	typewriter.start_typing(detail_one_label, detail_one_text)

func _on_detail_one_typing_done():
	print("Detail one typing finished!")
	typewriter.typing_finished.disconnect(_on_detail_one_typing_done)
	typewriter.typing_finished.connect(_on_detail_two_typing_done)
	typewriter.start_typing(detail_two_label, detail_two_text)


func _on_detail_two_typing_done():
	print("Detail two typing finished!")
	typewriter.typing_finished.disconnect(_on_detail_two_typing_done)
	typewriter.typing_finished.connect(_on_detail_three_typing_done)
	typewriter.start_typing(detail_three_label, detail_three_text)
	
func _on_detail_three_typing_done():
	print("Detail three typing finished!")
	typewriter.typing_finished.disconnect(_on_detail_three_typing_done)
	typewriter.typing_finished.connect(_on_detail_four_typing_done)
	typewriter.start_typing(detail_four_label, detail_four_text)
	
func _on_detail_four_typing_done():
	print("Detail four typing finished!")
	typewriter.typing_finished.disconnect(_on_detail_four_typing_done)
	typewriter.typing_finished.connect(_on_detail_five_typing_done)
	typewriter.start_typing(detail_five_label, detail_five_text)
	
func _on_detail_five_typing_done():
	print("Detail five typing finished!")
	typewriter.typing_finished.disconnect(_on_detail_five_typing_done)
	typewriter.typing_finished.connect(_on_detail_six_typing_done)
	typewriter.start_typing(detail_six_label, detail_six_text)
	
func _on_detail_six_typing_done():
	print("Detail six typing finished!")
	typewriter.typing_finished.disconnect(_on_detail_six_typing_done)
	typewriter.typing_finished.connect(_on_detail_seven_typing_done)
	typewriter.start_typing(detail_seven_label, detail_seven_text)
	
func _on_detail_seven_typing_done():
	print("Detail seven typing finished!")
	navigation_buttons.show()
