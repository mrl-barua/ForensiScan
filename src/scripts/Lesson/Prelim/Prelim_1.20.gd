extends Node2D

@export var header_text: String = "Principles of Fingerprints"
@export var detail_one_text: String = "- Uniqueness – No two fingerprints are the same."
@export var detail_two_text: String = "- Permanence – Fingerprints do not change during a person’s lifetime."
@export var detail_three_text: String = "- Universality – All humans have fingerprints."
@export var detail_four_text: String = "- Classifiability – Prints can be grouped into patterns for easy identification."

@onready var header_label: RichTextLabel = $VBoxContainer/Header
@onready var detail_one_label: RichTextLabel = $VBoxContainer/DetailOne 
@onready var detail_two_label: RichTextLabel = $VBoxContainer/DetailTwo 
@onready var detail_three_label: RichTextLabel = $VBoxContainer/DetailThree
@onready var detail_four_label: RichTextLabel = $VBoxContainer/DetailFour
var typewriter: Typewriter

@onready var navigation_buttons: Control = $NavigationControls

func _ready():
	# Track progress for this lesson
	ProgressManager.update_lesson_progress("prelim", 20)
	
	header_label.text = ''
	detail_one_label.text = ''
	detail_two_label.text = ''
	detail_three_label.text = ''
	detail_four_label.text = ''
	typewriter = Typewriter.new()
	add_child(typewriter)  
	
	typewriter.connect("typing_finished", Callable(self, "_on_header_typing_done"))
	typewriter.start_typing(header_label, header_text)

func _on_header_typing_done():
	print("Header typing finished!")
	typewriter.disconnect("typing_finished", Callable(self, "_on_header_typing_done"))
	typewriter.connect("typing_finished", Callable(self, "_on_detail_one_typing_done"))
	typewriter.start_typing(detail_one_label, detail_one_text)

func _on_detail_one_typing_done():
	print("Detail one typing finished!")
	typewriter.disconnect("typing_finished", Callable(self, "_on_detail_one_typing_done"))
	typewriter.connect("typing_finished", Callable(self, "_on_detail_two_typing_done"))
	typewriter.start_typing(detail_two_label, detail_two_text)

func _on_detail_two_typing_done():
	print("Detail two typing finished!")
	typewriter.disconnect("typing_finished", Callable(self, "_on_detail_two_typing_done"))
	typewriter.connect("typing_finished", Callable(self, "_on_detail_three_typing_done"))
	typewriter.start_typing(detail_three_label, detail_three_text)	
	
func _on_detail_three_typing_done():
	print("Detail three typing finished!")
	typewriter.disconnect("typing_finished", Callable(self, "_on_detail_three_typing_done"))
	typewriter.connect("typing_finished", Callable(self, "_on_detail_four_typing_done"))
	typewriter.start_typing(detail_four_label, detail_four_text)	
	
func _on_detail_four_typing_done():
	print("Detail four typing finished!")
	navigation_buttons.show()		


func _on_next_button_pressed():
	get_tree().change_scene_to_file_to_file("res://src/scenes/Lesson/Prelim/Prelim_1.21.tscn")
