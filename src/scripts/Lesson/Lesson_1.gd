extends Node2D

@export var lesson_1_text: String = "Lorem ipsum dolor sit amet consectetur adipiscing elit. Consectetur adipiscing elit quisque faucibus ex sapien vitae. Ex sapien vitae pellentesque sem placerat in id. Placerat in id cursus mi pretium tellus duis. Pretium tellus duis convallis tempus leo eu aenean."
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
	get_tree().change_scene_to_file("res://src/scenes/Lesson/Lesson_1.1.tscn")
