extends Node2D

@export var quit_button: Button
@onready var license_verifier: LicenseVerifier = $LicenseVerifier


func _ready() -> void:
	if license_verifier.is_activated():
		license_verifier.get_node("CanvasLayer").hide()
	else:
		license_verifier.get_node("CanvasLayer").show()

	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)

func _on_start_lesson_button_pressed():
	get_tree().change_scene_to_file("res://src/scenes/Lesson/Lesson_1.tscn")
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()

