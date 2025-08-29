extends Node2D

@export var header_text: String = "How did we discover fingerprints?"
@export var detail_one_text: String = "- This Bertillon System, named after its inventor, Alphonse Bertillon, was generally accepted for thirty years."
@export var detail_two_text: String = "- Around 1870 a French anthropologist devised a system to measure and record the dimensions of certain bony parts of the body."
@export var detail_three_text: String = "- These measurements were reduced to a formula which, theoretically, would apply only to one person and would not change during his/her adult life."

@onready var header_label: RichTextLabel = $VBoxContainer/Header
@onready var detail_one_label: RichTextLabel = $VBoxContainer/DetailOne 
@onready var detail_two_label: RichTextLabel = $VBoxContainer/DetailTwo 
@onready var detail_three_label: RichTextLabel = $VBoxContainer/DetailThree
var typewriter: Typewriter

@onready var navigation_buttons: Control = $NavigationControls

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
	navigation_buttons.show()	
