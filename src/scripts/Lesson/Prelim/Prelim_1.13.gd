extends Node2D

@export var header_text: String = "Important People in Fingerprinting History!"
@export var detail_one_text: String = "- Dr. Henry Faulds "
@export var detail_two_text: String = "- the British Surgeon-Superintendent of Tsukiji Hospital in Tokyo, Japan, took up the study of 'skin-furrows' after noticing finger marks on specimens of 'prehistoric' pottery. "
@export var detail_three_text: String = "- 1880, Faulds forwarded an explanation of his classification system and a sample of the forms he had designed for recording inked impressions, to Sir Charles Darwin."
@export var detail_four_text: String = "He discussed fingerprints as a means of personal identification, and the use of printers ink as a method for obtaining such fingerprints."

@onready var header_label: RichTextLabel = $VBoxContainer/Header
@onready var detail_one_label: RichTextLabel = $VBoxContainer/DetailOne 
@onready var detail_two_label: RichTextLabel = $VBoxContainer/DetailTwo 
@onready var detail_three_label: RichTextLabel = $VBoxContainer/DetailThree
@onready var detail_four_label: RichTextLabel = $VBoxContainer/DetailFour
var typewriter: Typewriter

@onready var navigation_buttons: Control = $NavigationControls

func _ready():
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
	print('Detail four typing finished!')
	navigation_buttons.show()	

