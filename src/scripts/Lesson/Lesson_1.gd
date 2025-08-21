extends Node2D

@export var full_text: String = "Lorem ipsum dolor sit amet consectetur adipiscing elit. Consectetur adipiscing elit quisque faucibus ex sapien vitae. Ex sapien vitae pellentesque sem placerat in id. Placerat in id cursus mi pretium tellus duis. Pretium tellus duis convallis tempus leo eu aenean."
@export var delay: float = 0.05  

var _current_index := 0
var _typing := false
var _skip := false
@onready var label: RichTextLabel = $Label

func _ready():
	start_typing()

func start_typing():
	_typing = true
	_skip = false
	_current_index = 0
	label.text = ""
	_show_next_letter()

func _show_next_letter():
	if _skip:
		label.text = full_text
		_typing = false
		return
	
	if _current_index < full_text.length():
		label.text += full_text[_current_index]
		_current_index += 1
		await get_tree().create_timer(delay).timeout
		_show_next_letter()
	else:
		_typing = false

func skip_typing():
	_skip = true

func _input(event):
	if event.is_action_pressed("ui_accept") and _typing:
		skip_typing()

	if event is InputEventScreenTouch and event.pressed and _typing:
		skip_typing()

