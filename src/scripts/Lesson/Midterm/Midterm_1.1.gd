extends Node2D

@export var header_text: String = "HOW TO TAKE FINGERPRINTS"
@onready var header: RichTextLabel = $VBoxContainer/Header
@onready var navigation_buttons: Control = $NavigationControls
var typewriter: Typewriter

func _ready():
	typewriter = Typewriter.new()
	add_child(typewriter)  
	
	typewriter.typing_finished.connect(_on_typing_done)
	typewriter.start_typing(header, header_text)
	
func _on_typing_done():
	print("Midterm 1.1: Typing finished! Showing navigation buttons...")
	print("Midterm 1.1: NavigationControls before show() = ", navigation_buttons.visible)
	navigation_buttons.show()
	print("Midterm 1.1: NavigationControls after show() = ", navigation_buttons.visible)
	
