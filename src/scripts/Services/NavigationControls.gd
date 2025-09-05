extends Control

@export var hide_previous_button: bool = false
@export var hide_next_button: bool = false

@export_file("*.tscn") var previous_scene_path: String
@export_file("*.tscn") var next_scene_path: String

@onready var previous_button: TextureButton = $HBoxContainer/PreviousButton
@onready var next_button: TextureButton = $HBoxContainer/NextButton
@onready var page_indicator: Label = $HBoxContainer/PageIndicator

var current_page: int = 1
var total_pages: int = 25
var tween: Tween

func _ready():
	previous_button.disabled = hide_previous_button
	previous_button.modulate.a = 0.5 if hide_previous_button else 1.0

	next_button.disabled = hide_next_button
	next_button.modulate.a = 0.5 if hide_next_button else 1.0

	if not previous_button.pressed.is_connected(_on_previous_button_pressed):
		previous_button.pressed.connect(_on_previous_button_pressed)

	if not next_button.pressed.is_connected(_on_next_button_pressed):
		next_button.pressed.connect(_on_next_button_pressed)
		
	# Add hover effects
	previous_button.mouse_entered.connect(_on_button_hover.bind(previous_button))
	previous_button.mouse_exited.connect(_on_button_unhover.bind(previous_button))
	next_button.mouse_entered.connect(_on_button_hover.bind(next_button))
	next_button.mouse_exited.connect(_on_button_unhover.bind(next_button))
	
	# Extract page number from scene path for indicator
	_update_page_indicator()

func _on_button_hover(button: TextureButton):
	if button.disabled:
		return
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.1)

func _on_button_unhover(button: TextureButton):
	if button.disabled:
		return
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(button, "scale", Vector2(0.8, 0.8), 0.1)

func _update_page_indicator():
	# Try to extract page number from current scene
	var scene_name = get_tree().current_scene.scene_file_path.get_file()
	var regex = RegEx.new()
	regex.compile(r"(\d+)")
	var result = regex.search(scene_name)
	if result:
		current_page = result.get_string().to_int()
	
	page_indicator.text = "Page %d of %d" % [current_page, total_pages]

func _on_previous_button_pressed():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(previous_button, "scale", Vector2(0.7, 0.7), 0.05)
	tween.tween_property(previous_button, "scale", Vector2(0.8, 0.8), 0.05)
	_change_scene_to_file(previous_scene_path)

func _on_next_button_pressed():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(next_button, "scale", Vector2(0.7, 0.7), 0.05)
	tween.tween_property(next_button, "scale", Vector2(0.8, 0.8), 0.05)
	_change_scene_to_file(next_scene_path)

func _change_scene_to_file(path: String) -> void:
	if path != "":
		var packed_scene: PackedScene = load(path)
		if packed_scene:
			get_tree().change_scene_to_packed(packed_scene)
