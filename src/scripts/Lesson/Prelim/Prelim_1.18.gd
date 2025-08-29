extends Node2D

@export var header_text: String = "Fundamentals of Personal Identification"
@export var detail_one_text: String = "- Fingerprint Identification (Summary & Activities) "

@onready var header_label: RichTextLabel = $VBoxContainer/Header
@onready var detail_one_label: RichTextLabel = $VBoxContainer/DetailOne 
var typewriter: Typewriter

@onready var next_button: Button = $NextButton

func _ready():
	header_label.text = ''
	detail_one_label.text = ''
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
	next_button.show()
	
func _on_next_button_pressed():
	get_tree().change_scene_to_file("res://src/scenes/Lesson/Prelim/Prelim_1.19.tscn")
