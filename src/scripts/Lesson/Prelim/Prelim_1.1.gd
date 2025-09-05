extends Node2D

@export var header_text: String = "THE HISTORY & DEVELOPMENT OF FINGERPRINT"
@onready var header: RichTextLabel = $VBoxContainer/Header
@onready var navigation_buttons: Control = $NavigationControls
var typewriter: Typewriter

func _ready():
	print("Lesson _ready: NavigationControls visible = ", navigation_buttons.visible)
	typewriter = Typewriter.new()
	add_child(typewriter)  
	
	print("Lesson: Connecting typing_finished signal")
	typewriter.typing_finished.connect(_on_typing_done)
	typewriter.start_typing(header, header_text)
	
func _on_typing_done():
	print("Lesson: Typing finished! Showing navigation buttons...")
	print("Lesson: NavigationControls before show() = ", navigation_buttons.visible)
	navigation_buttons.show()
	print("Lesson: NavigationControls after show() = ", navigation_buttons.visible)
	
