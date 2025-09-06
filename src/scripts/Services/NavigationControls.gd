extends Control

@export var hide_previous_button: bool = false
@export var hide_next_button: bool = false
@export var manual_page_number: int = 0  # Set to 0 for auto-detection, or set specific page number

@export_file("*.tscn") var previous_scene_path: String
@export_file("*.tscn") var next_scene_path: String

@onready var previous_button: TextureButton = $HBoxContainer/PreviousButton
@onready var next_button: TextureButton = $HBoxContainer/NextButton
@onready var page_indicator: Label = $HBoxContainer/PageIndicator

var current_page: int = 1
var total_pages: int = 25  # Default for Prelim lessons
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
	
	# Connect to visibility changed to update page indicator when shown
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if visible:
		# Wait a frame to ensure scene is properly loaded
		await get_tree().process_frame
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
	# If manual page number is set, use that
	if manual_page_number > 0:
		current_page = manual_page_number
		page_indicator.text = "Page %d of %d" % [current_page, total_pages]
		print("NavigationControls: Using manual page number: ", current_page)
		return
	
	# Try to extract page number from current scene
	var scene = get_tree().current_scene
	if not scene:
		page_indicator.text = "Page 1 of %d" % total_pages
		return
		
	var scene_name = scene.scene_file_path.get_file()
	print("NavigationControls: Extracting page from scene: ", scene_name)
	
	# Auto-detect lesson type and set total pages
	if "Midterm" in scene_name:
		total_pages = 65  # Midterm has 65 lessons
	elif "Prelim" in scene_name:
		total_pages = 25  # Prelim has 25 lessons
	
	# Create regex to find the page number
	var regex = RegEx.new()
	var result
	
	# Try Midterm pattern first (e.g., "Midterm_1.15" -> "15")
	if "Midterm" in scene_name:
		regex.compile(r"Midterm_1\.(\d+)")
		result = regex.search(scene_name)
		if result:
			current_page = result.get_string(1).to_int()
			print("NavigationControls: Found Midterm page number: ", current_page)
		else:
			# Fallback for Midterm
			regex.compile(r"(\d+)")
			result = regex.search(scene_name)
			if result:
				var found_number = result.get_string().to_int()
				if found_number >= 1 and found_number <= total_pages:
					current_page = found_number
					print("NavigationControls: Using fallback Midterm page number: ", current_page)
				else:
					current_page = 1
					print("NavigationControls: Midterm number out of range, defaulting to page 1")
			else:
				current_page = 1
				print("NavigationControls: No Midterm number found, defaulting to page 1")
	
	# Try Prelim pattern (e.g., "Prelim_1.15" -> "15")
	elif "Prelim" in scene_name:
		regex.compile(r"Prelim_1\.(\d+)")
		result = regex.search(scene_name)
		if result:
			current_page = result.get_string(1).to_int()
			print("NavigationControls: Found Prelim page number: ", current_page)
		else:
			# Fallback for Prelim
			regex.compile(r"(\d+)")
			result = regex.search(scene_name)
			if result:
				var found_number = result.get_string().to_int()
				if found_number >= 1 and found_number <= total_pages:
					current_page = found_number
					print("NavigationControls: Using fallback Prelim page number: ", current_page)
				else:
					current_page = 1
					print("NavigationControls: Prelim number out of range, defaulting to page 1")
			else:
				current_page = 1
				print("NavigationControls: No Prelim number found, defaulting to page 1")
	
	else:
		# Unknown lesson type, try generic pattern
		regex.compile(r"(\d+)")
		result = regex.search(scene_name)
		if result:
			var found_number = result.get_string().to_int()
			if found_number >= 1 and found_number <= total_pages:
				current_page = found_number
				print("NavigationControls: Using generic page number: ", current_page)
			else:
				current_page = 1
				print("NavigationControls: Generic number out of range, defaulting to page 1")
		else:
			current_page = 1
			print("NavigationControls: No number found, defaulting to page 1")
	
	page_indicator.text = "Page %d of %d" % [current_page, total_pages]
	print("NavigationControls: Page indicator updated to: ", page_indicator.text)

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

func set_page_number(page: int, total: int = -1):
	"""Manually set the current page number and optionally total pages"""
	current_page = page
	if total > 0:
		total_pages = total
	page_indicator.text = "Page %d of %d" % [current_page, total_pages]
	print("NavigationControls: Manually set page to %d of %d" % [current_page, total_pages])

func _change_scene_to_file(path: String) -> void:
	if path != "":
		var packed_scene: PackedScene = load(path)
		if packed_scene:
			get_tree().change_scene_to_packed(packed_scene)
