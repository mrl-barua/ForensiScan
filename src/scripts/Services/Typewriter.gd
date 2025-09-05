extends Node
class_name Typewriter

@export var delay: float = 0.05

var _segments: Array = []
var _current_index := 0
var _typing := false
var _skip := false
var _label: RichTextLabel
var _paused := false

signal typing_finished

func _ready():
	# Add to a group for pause system integration
	add_to_group("typewriters")

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
	_paused = false
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
		
		# Respect pause state - wait for resume if paused
		await get_tree().create_timer(delay).timeout
		
		# Check again if we should continue after the delay
		if not _paused and _typing:
			_show_next_segment()
	else:
		_typing = false
		emit_signal("typing_finished") 

func skip_typing():
	_skip = true

func pause_typing():
	_paused = true

func resume_typing():
	var was_paused = _paused
	_paused = false
	# If we were typing and paused, continue
	if was_paused and _typing:
		_show_next_segment()

func _input(event):
	# Don't accept input when paused
	if ApplicationManager.is_paused():
		return
		
	if event.is_action_pressed("ui_accept") and _typing:
		skip_typing()

	if event is InputEventScreenTouch and event.pressed and _typing:
		skip_typing()
