extends Node2D

@export var header_text: String = "Sir Edward Richard Henry"
@export var detail_one_text: String = "- Known as the Father of Fingerprints"
@export var detail_two_text: String = "- The first man who successfully applied fingerprints in Identification."
@export var detail_three_text: String = "- In 1890 he became a secretary to the Lieutenant Governor of Bengal and later appointed Inspector General of Police, where around that time he started working on his fingerprint identification system."

@onready var header_label: RichTextLabel = $VBoxContainer/Header
@onready var detail_one_label: RichTextLabel = $VBoxContainer/DetailOne 
@onready var detail_two_label: RichTextLabel = $VBoxContainer/DetailTwo 
@onready var detail_three_label: RichTextLabel = $VBoxContainer/DetailThree
var typewriter: Typewriter

@onready var next_button: Button = $NextButton

func _ready():
	header_label.text = ''
	detail_one_label.text = ''
	detail_two_label.text = ''
	detail_three_label.text = ''
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
	next_button.show()	

func _on_next_button_pressed():
	get_tree().change_scene_to_file("res://src/scenes/Lesson/Prelim/Prelim_1.10.tscn")
