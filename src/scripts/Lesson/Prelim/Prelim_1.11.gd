extends Node2D

@export var header_text: String = "Important People in Fingerprinting History!"
@export var detail_one_text: String = "- Sir William Hershel"
@export var detail_two_text: String = "- credited with being the first European to note the value of fingerprints for identification. He recognized that fingerprints were unique and permanent. Herschel documented his own fingerprints over his lifetime to prove permanence. He was also credited with being the first person to use fingerprints in a practical manner. As early as the 1850s, working as a British officer for the Indian Civil Service in the Bengal region of India, he started putting fingerprints on contracts."

@onready var header_label: RichTextLabel = $Header
@onready var detail_one_label: RichTextLabel = $DetailOne 
@onready var detail_two_label: RichTextLabel = $DetailTwo 
var typewriter: Typewriter

@onready var next_button: Button = $NextButton

func _ready():
	header_label.text = ''
	detail_one_label.text = ''
	detail_two_label.text = ''
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
	next_button.show()

func _on_next_button_pressed():
	get_tree().change_scene_to_file("res://src/scenes/Lesson/Prelim/Prelim_1.3.tscn")
