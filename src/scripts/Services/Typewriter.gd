extends Node
class_name Typewriter

@export var delay: float = 0.05

var _segments: Array = []
var _current_index := 0
var _typing := false
var _skip := false
var _label: RichTextLabel

signal typing_finished

func start_typing(label: RichTextLabel, text: String):
	"""
	Starts the typewriter effect on a given RichTextLabel with the provided BBCode text.
	Splits by space for word-by-word typing.
	"""
	_label = label
	_label.bbcode_enabled = true
	_segments = text.split(" ")
	_typing = true
	_skip = false
	_current_index = 0
	_label.text = ""
	_show_next_segment()

func _show_next_segment():
	if _skip:
		_label.text = " ".join(_segments)
		_typing = false
		emit_signal("typing_finished")
		return

	if _current_index < _segments.size():
		_label.text += _segments[_current_index] + " "
		_current_index += 1
		await get_tree().create_timer(delay).timeout
		_show_next_segment()
	else:
		_typing = false
		emit_signal("typing_finished") 

func skip_typing():
	_skip = true

func _input(event):
	if event.is_action_pressed("ui_accept") and _typing:
		skip_typing()

	if event is InputEventScreenTouch and event.pressed and _typing:
		skip_typing()
