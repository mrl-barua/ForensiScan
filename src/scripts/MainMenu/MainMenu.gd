extends Node2D

@export var quit_button: Button

func _ready() -> void:
	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
