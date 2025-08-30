extends Control

@export var hide_previous_button: bool = false
@export var hide_next_button: bool = false

@export_file("*.tscn") var previous_scene_path: String
@export_file("*.tscn") var next_scene_path: String

@onready var previous_button: TextureButton = $HBoxContainer/PreviousButton
@onready var next_button: TextureButton = $HBoxContainer/NextButton


func _ready():
	previous_button.disabled = hide_previous_button
	previous_button.modulate.a = 0.0 if hide_previous_button else 1.0

	next_button.disabled = hide_next_button
	next_button.modulate.a = 0.0 if hide_next_button else 1.0

	if not previous_button.pressed.is_connected(_on_previous_button_pressed):
		previous_button.pressed.connect(_on_previous_button_pressed)

	if not next_button.pressed.is_connected(_on_next_button_pressed):
		next_button.pressed.connect(_on_next_button_pressed)


func _on_previous_button_pressed():
	_change_scene(previous_scene_path)


func _on_next_button_pressed():
	_change_scene(next_scene_path)


func _change_scene(path: String) -> void:
	if path != "":
		var packed_scene: PackedScene = load(path)
		if packed_scene:
			get_tree().change_scene_to_packed(packed_scene)
