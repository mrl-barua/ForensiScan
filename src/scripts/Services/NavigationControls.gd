extends Control

@export var hide_previous_button: bool = false
@export var hide_next_button: bool = false

@export var previous_scene: PackedScene
@export var next_scene: PackedScene

@export_file("*.tscn") var previous_scene_path: String
@export_file("*.tscn") var next_scene_path: String

@onready var previous_button: Button = $HBoxContainer/PreviousButton
@onready var next_button: Button = $HBoxContainer/NextButton


func _ready():
	previous_button.visible = not hide_previous_button
	next_button.visible = not hide_next_button

	if not previous_button.pressed.is_connected(_on_previous_button_pressed):
		previous_button.pressed.connect(_on_previous_button_pressed)

	if not next_button.pressed.is_connected(_on_next_button_pressed):
		next_button.pressed.connect(_on_next_button_pressed)


func _on_previous_button_pressed():
	var target_scene = _get_scene(previous_scene, previous_scene_path)
	if target_scene:
		get_tree().change_scene_to_packed(target_scene)


func _on_next_button_pressed():
	var target_scene = _get_scene(next_scene, next_scene_path)
	if target_scene:
		get_tree().change_scene_to_packed(target_scene)


# Helper to pick between PackedScene or path string
func _get_scene(scene: PackedScene, path: String) -> PackedScene:
	if scene:
		return scene
	elif path != "":
		var loaded_scene = load(path)
		if loaded_scene is PackedScene:
			return loaded_scene
	return null
