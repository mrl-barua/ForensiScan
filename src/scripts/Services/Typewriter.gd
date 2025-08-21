extends Node
class_name Typewriter   

@export var delay: float = 0.05 

var _full_text: String = ""
var _current_index := 0
var _typing := false
var _skip := false
var _label: RichTextLabel

func start_typing(label: RichTextLabel, text: String):
	"""
	Starts the typewriter effect on a given RichTextLabel with the provided text.
	"""
	_label = label
	_full_text = text
	_typing = true
	_skip = false
	_current_index = 0
	_label.text = ""
	_show_next_letter()

func _show_next_letter():
	if _skip:
		_label.text = _full_text
		_typing = false
		return
	
	if _current_index < _full_text.length():
		_label.text += _full_text[_current_index]
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
