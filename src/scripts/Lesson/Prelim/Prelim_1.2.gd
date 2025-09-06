extends Node2D

@export var header_text: String = "What happened before fingerprints?"
@export var detail_one_text: String = "[color=yellow]- Picture writing of a hand with ridge patterns was discovered in Nova Scotia.[/color]"
@export var detail_two_text: String = "[color=blue]- Ancient Babylon [/color][color=red], fingerprints were used on clay tablets for business transactions[/color]"

@onready var header_label: RichTextLabel = $VBoxContainer/Header
@onready var detail_one_label: RichTextLabel = $VBoxContainer/DetailOne 
@onready var detail_two_label: RichTextLabel = $VBoxContainer/DetailTwo 
var typewriter: Typewriter

@onready var navigation_buttons: Control = $NavigationControls

func _ready():
	# Track progress for this lesson
	ProgressManager.update_lesson_progress("prelim", 2)
	
	header_label.text = ''
	detail_one_label.text = ''
	detail_two_label.text = ''
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
	navigation_buttons.show()
