extends Node2D

@export var header_text: String = "THE HISTORY & DEVELOPMENT OF FINGERPRINT"
@onready var header: RichTextLabel = $VBoxContainer/Header
@onready var next_button: Control = $NavigationControls
var typewriter: Typewriter

func _ready():
	typewriter = Typewriter.new()
	add_child(typewriter)  
	
	typewriter.connect("typing_finished", Callable(self, "_on_typing_done"))
	typewriter.start_typing(header, header_text)
	
func _on_typing_done():
	print("Typing finished!")
	next_button.show();
	
func _on_next_button_pressed():
	get_tree().change_scene_to_file("res://src/scenes/Lesson/Prelim/Prelim_1.2.tscn")
