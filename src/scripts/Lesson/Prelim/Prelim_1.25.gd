extends Node2D

@export var header_text: String = "Forensic & Legal Importance"
@export var detail_one_text: String = "- Fingerprints are strong evidence in courts due to their uniqueness."
@export var detail_two_text: String = "- Used in crime investigations, border security, and identity verification."
@export var detail_three_text: String = "- Accepted globally as reliable proof of identity."

@onready var header_label: RichTextLabel = $VBoxContainer/Header
@onready var detail_one_label: RichTextLabel = $VBoxContainer/DetailOne 
@onready var detail_two_label: RichTextLabel = $VBoxContainer/DetailTwo 
@onready var detail_three_label: RichTextLabel = $VBoxContainer/DetailThree
var typewriter: Typewriter

@onready var proceed_to_quiz_button: Button = $ProceedToQuizButton
@onready var go_back_to_menu_button: Button = $GoBackToMenuButton

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
	proceed_to_quiz_button.show();
	go_back_to_menu_button.show()

func _on_proceed_to_quiz_button_pressed():
	get_tree().change_scene_to_file_to_file("res://src/scenes/Quiz/Prelim/Prelim_Quiz_1.1.tscn")

func _on_go_back_to_menu_button_pressed():
	get_tree().change_scene_to_file_to_file("res://src/scenes/MainMenu.tscn")
