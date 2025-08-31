extends Node2D

@export var header_text: String = "THE HISTORY & DEVELOPMENT OF FINGERPRINT"
@onready var header: RichTextLabel = $VBoxContainer/Header
@onready var navigation_buttons: Control = $NavigationControls
var typewriter: Typewriter

func _ready():
	typewriter = Typewriter.new()
	add_child(typewriter)  
	
	typewriter.connect("typing_finished", Callable(self, "_on_typing_done"))
	typewriter.start_typing(header, header_text)
	
func _on_typing_done():
	print("Typing finished!")
	navigation_buttons.show();
	
