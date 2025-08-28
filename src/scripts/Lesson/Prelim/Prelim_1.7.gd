extends Node2D

@export var detail_one_text: String = "- Upon an investigation, there were indeed two men! They looked exactly alike, but were allegedly not related. Their names were Will and William West respectively. Their Bertillon measurements were close enough to identify them as the same person."
@export var detail_two_text: String = "- A fingerprint comparison quickly and correctly identified them as two different people. The West men were apparently identical twin brothers per indications in later discovered prison records citing correspondence from the same immediate family relatives."

@onready var detail_one_label: RichTextLabel = $DetailOne 
@onready var detail_two_label: RichTextLabel = $DetailTwo 
var typewriter: Typewriter

@onready var next_button: Button = $NextButton

func _ready():
	detail_one_label.text = ''
	detail_two_label.text = ''
	typewriter = Typewriter.new()
	add_child(typewriter)  

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
	pass
