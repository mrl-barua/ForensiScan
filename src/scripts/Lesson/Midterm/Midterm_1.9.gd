extends Node2D

@export var header_text: String = ""
@export var detail_one_text: String = "- Failure to roll the fingers fully from one side to the other and failure to ink the entire finger area from tip to below the first joint. Such failures result in important areas not appearing on the print. The impression should show the entire finger, from the first joint to the tip, and from one side to the other side.
"
@export var detail_two_text: String = "- The use of too much ink, resulting in the obliteration of ridges. Just a touch of the tube of ink to the plate is sufficient for several sets of prints. It must be spread with a roller into a thin, even film.
"
@export var detail_three_text: String = "- The use of too little ink, resulting in ridge impressions too light and too faint for tracing or counting."
@export var detail_four_text: String = "- Slipping or twisting of the fingers, causing smears, blurs, and false patterns. Hold the fingers lightly, using little pressure, and caution the person against trying to help. Ask him or her to remain quiet and relaxed.
"
@export var detail_five_text: String = ""
@export var detail_six_text: String = ""
@export var detail_seven_text: String = ""

@onready var header_label: RichTextLabel = $VBoxContainer/Header
@onready var detail_one_label: RichTextLabel = $VBoxContainer/DetailOne 
@onready var detail_two_label: RichTextLabel = $VBoxContainer/DetailTwo
@onready var detail_three_label: RichTextLabel = $VBoxContainer/DetailThree
@onready var detail_four_label: RichTextLabel = $VBoxContainer/DetailFour
@onready var detail_five_label: RichTextLabel = $VBoxContainer/DetailFive
@onready var detail_six_label: RichTextLabel = $VBoxContainer/DetailSix
@onready var detail_seven_label: RichTextLabel = $VBoxContainer/DetailSeven
var typewriter: Typewriter

@onready var navigation_buttons: Control = $NavigationControls

func _ready():
	header_label.text = ''
	detail_one_label.text = ''
	detail_two_label.text = ''
	detail_three_label.text = ''
	detail_four_label.text = ''
	detail_five_label.text = ''
	detail_six_label.text = ''
	detail_seven_label.text = ''
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
	typewriter.disconnect("typing_finished", Callable(self, "_on_detail_four_typing_done"))
	typewriter.connect("typing_finished", Callable(self, "_on_detail_five_typing_done"))
	typewriter.start_typing(detail_five_label, detail_five_text)
	
func _on_detail_five_typing_done():
	print("Detail five typing finished!")
	typewriter.disconnect("typing_finished", Callable(self, "_on_detail_five_typing_done"))
	typewriter.connect("typing_finished", Callable(self, "_on_detail_six_typing_done"))
	typewriter.start_typing(detail_six_label, detail_six_text)
	
func _on_detail_six_typing_done():
	print("Detail six typing finished!")
	typewriter.disconnect("typing_finished", Callable(self, "_on_detail_six_typing_done"))
	typewriter.connect("typing_finished", Callable(self, "_on_detail_seven_typing_done"))
	typewriter.start_typing(detail_seven_label, detail_seven_text)
	
func _on_detail_seven_typing_done():
	print("Detail seven typing finished!")
	navigation_buttons.show()
