extends Node2D

@export var header_text: String = "What happened before fingerprints?"
@export var detail_one_text: String = "- In earlier civilizations, branding and even maiming were used to mark the criminal for what he was. The Romans tattooed to identify and prevent desertion of mercenary soldiers. "
@export var detail_two_text: String = "- More recently, law enforcement officers with extraordinary visual memories, so-called 'camera eyes,' identified old offenders by sight. Photography lessened the burden on memory but was not the answer to the criminal identification problem. Personal appearances change.
"

@onready var header_label: RichTextLabel = $VBoxContainer/Header
@onready var detail_one_label: RichTextLabel = $VBoxContainer/DetailOne 
@onready var detail_two_label: RichTextLabel = $VBoxContainer/DetailTwo 
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
	get_tree().change_scene_to_file("res://src/scenes/Lesson/Prelim/Prelim_1.4.tscn")
