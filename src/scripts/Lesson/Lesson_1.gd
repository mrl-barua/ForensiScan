extends Node2D

@export var lesson_1_text: String = "Lorem ipsum dolor sit amet consectetur adipiscing elit. Consectetur adipiscing elit quisque faucibus ex sapien vitae. Ex sapien vitae pellentesque sem placerat in id. Placerat in id cursus mi pretium tellus duis. Pretium tellus duis convallis tempus leo eu aenean."
@onready var label: RichTextLabel = $Label
var typewriter: Typewriter

func _ready():
	typewriter = Typewriter.new()
	add_child(typewriter)  
	typewriter.start_typing(label, lesson_1_text)

