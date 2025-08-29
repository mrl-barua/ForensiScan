extends Node2D

@export var header_text: String = "Important People in Fingerprinting History!"
@export var detail_one_text: String = "- Juan Vucetich "
@export var detail_two_text: String = "- In 1892, Juan Vucetich made the first criminal fingerprint identification. "
@export var detail_three_text: String = "- He was able to identify a woman by the name of Rojas, who had murdered her two sons, and cut her own throat in an attempt to place blame on another. Her bloody print was left on a door post, proving her identity as the murderer. This is believed to be the first criminal found guilty through fingerprint evidence in the world."
@export var detail_four_text: String = "https://www.history.com/this-day-in-history/a-bloody-fingerprint-elicits-a-mothers-evil-tale-in-argentina"

@onready var header_label: RichTextLabel = $VBoxContainer/Header
@onready var detail_one_label: RichTextLabel = $VBoxContainer/DetailOne 
@onready var detail_two_label: RichTextLabel = $VBoxContainer/DetailTwo 
@onready var detail_three_label: RichTextLabel = $VBoxContainer/DetailThree
@onready var detail_four_label: RichTextLabel = $VBoxContainer/DetailFour
var typewriter: Typewriter

@onready var next_button: Button = $NextButton

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
	print("Detail four typing finished!")
	next_button.show()		


func _on_next_button_pressed():
	get_tree().change_scene_to_file("res://src/scenes/Lesson/Prelim/Prelim_1.17.tscn")
