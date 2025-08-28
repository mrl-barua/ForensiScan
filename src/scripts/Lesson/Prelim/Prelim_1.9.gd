extends Node2D

@export var header_text: String = "Important People in Fingerprinting History!"
@export var detail_one_text: String = "- Marcello Malpighi"
@export var detail_two_text: String = "- In 1686, Marcello Malpighi, a professor of anatomy at the University of Bologna, noted ridges, spirals and loops in fingerprints. He made no mention of their value as a tool for individual identification. A layer of skin was named after him; 'Malpighi' layer, which is approximately 1.8mm thick."

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
