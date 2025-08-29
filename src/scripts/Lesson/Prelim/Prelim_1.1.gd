extends Node2D

@export var lesson_1_text: String = "THE HISTORY & DEVELOPMENT OF FINGERPRINT"
@onready var label: RichTextLabel = $Label
@onready var next_button: Button = $NextButton
var typewriter: Typewriter

func _ready():
	typewriter = Typewriter.new()
	add_child(typewriter)  
	
	typewriter.connect("typing_finished", Callable(self, "_on_typing_done"))
	typewriter.start_typing(label, lesson_1_text)
	
func _on_typing_done():
	print("Typing finished!")
	next_button.show();
	
func _on_next_button_pressed():
	get_tree().change_scene_to_file("res://src/scenes/Lesson/Prelim/Prelim_1.2.tscn")
