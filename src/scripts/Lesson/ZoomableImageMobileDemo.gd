extends Control

# Mobile-optimized demo script for ZoomableImage component

@onready var forensic_image_1: Control = $SafeAreaContainer/VBoxContainer/ImageGrid/ForensicImage1
@onready var forensic_image_2: Control = $SafeAreaContainer/VBoxContainer/ImageGrid/ForensicImage2
@onready var forensic_image_3: Control = $SafeAreaContainer/VBoxContainer/ImageGrid/ForensicImage3
@onready var forensic_image_4: Control = $SafeAreaContainer/VBoxContainer/ImageGrid/ForensicImage4
@onready var test_button: Button = $SafeAreaContainer/VBoxContainer/BottomControls/TestButton
@onready var back_button: Button = $SafeAreaContainer/VBoxContainer/BottomControls/BackButton

var images: Array[Control] = []
var current_test_image: int = 0

func _ready():
	setup_mobile_images()
	connect_signals()
	print("📱 Mobile ZoomableImage demo ready")

func setup_mobile_images():
	images = [forensic_image_1, forensic_image_2, forensic_image_3, forensic_image_4]
	
	# Configure each image for mobile use
	for i in range(images.size()):
		var image = images[i]
		
		# Set mobile-optimized properties
		image.enable_haptic_feedback = true
		image.modal_transition_duration = 0.25  # Faster transitions for mobile
		image.zoom_speed = 0.3  # More responsive zoom
		image.min_zoom = 0.2  # Allow more zoom out
		image.max_zoom = 10.0  # Allow more zoom in
		
		# Set return callbacks
		image.set_return_callback(_on_return_from_modal.bind(i))
		
		print("✅ Configured mobile image ", i + 1)

func connect_signals():
	# Connect to all image events for tracking
	for i in range(images.size()):
		var image = images[i]
		image.image_clicked.connect(_on_image_clicked.bind(i))
		image.fullscreen_opened.connect(_on_modal_opened.bind(i))
		image.fullscreen_closed.connect(_on_modal_closed.bind(i))

# Handle image clicks
func _on_image_clicked(image_index: int):
	print("📱 Mobile image ", image_index + 1, " clicked - opening modal")
	
	# Hide UI elements during modal
	hide_ui_for_modal()

# Handle modal opened
func _on_modal_opened(image_index: int):
	print("🖼️ Modal opened for image ", image_index + 1)
	
	# Additional mobile-specific setup
	setup_modal_environment()

# Handle modal closed
func _on_modal_closed(image_index: int):
	print("❌ Modal closed for image ", image_index + 1)
	
	# Restore mobile UI
	restore_ui_from_modal()

# Handle return from modal
func _on_return_from_modal(image_index: int):
	print("↩️ Returned from modal for image ", image_index + 1)
	
	# Could track viewing time, update progress, etc.
	track_image_interaction(image_index)

# Hide UI elements during modal
func hide_ui_for_modal():
	test_button.visible = false
	back_button.visible = false

# Restore UI after modal
func restore_ui_from_modal():
	test_button.visible = true
	back_button.visible = true

# Setup modal environment for mobile
func setup_modal_environment():
	# Keep screen on during image viewing
	if OS.get_name() == "Android":
		OS.set_low_processor_usage_mode(false)

# Track image interaction for analytics
func track_image_interaction(image_index: int):
	print("📊 Tracked interaction with evidence image ", image_index + 1)
	# Could save to progress manager, analytics, etc.

# Test button to programmatically open modal
func _on_test_button_pressed():
	print("🧪 Testing programmatic modal open")
	
	var image = images[current_test_image]
	image.open_modal()
	
	# Cycle through images for testing
	current_test_image = (current_test_image + 1) % images.size()

# Navigate back to main menu
func _on_back_button_pressed():
	print("← Returning to main menu")
	get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn")

# Handle Android back button
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_BACK:
			# Check if any modal is open
			var modal_open = false
			for image in images:
				if image.is_modal_open:
					modal_open = true
					image.close_modal()
					break
			
			# If no modal open, go back to menu
			if not modal_open:
				_on_back_button_pressed()

# Mobile-specific utilities
func get_safe_area() -> Rect2:
	# Get device safe area (avoiding notches, etc.)
	var screen_size = get_viewport().get_visible_rect().size
	var safe_margin = 40  # Default safe margin
	
	return Rect2(
		Vector2(safe_margin, safe_margin * 2),  # Extra top margin for status bar
		screen_size - Vector2(safe_margin * 2, safe_margin * 3)
	)

func is_tablet() -> bool:
	# Simple tablet detection
	var screen_size = get_viewport().get_visible_rect().size
	var diagonal = sqrt(screen_size.x * screen_size.x + screen_size.y * screen_size.y)
	return diagonal > 1400  # Rough tablet threshold

func adapt_for_device():
	# Adapt UI based on device type
	var image_size = Vector2(250, 200) if is_tablet() else Vector2(300, 250)
	
	for image in images:
		image.set_preview_size(image_size)

func _notification(what):
	match what:
		NOTIFICATION_WM_GO_BACK_REQUEST:
			# Handle Android hardware back button
			_input(InputEventKey.new())
		NOTIFICATION_APPLICATION_PAUSED:
			# Handle app going to background
			print("📱 App paused - closing any open modals")
			for image in images:
				if image.is_modal_open:
					image.close_modal()
		NOTIFICATION_APPLICATION_RESUMED:
			# Handle app coming back to foreground
			print("📱 App resumed")

# Example of integration with forensic education system
func load_forensic_case_images(case_id: String):
	var case_images = [
		"res://assets/images/Cases/" + case_id + "/fingerprint.jpg",
		"res://assets/images/Cases/" + case_id + "/scene.jpg",
		"res://assets/images/Cases/" + case_id + "/evidence.jpg",
		"res://assets/images/Cases/" + case_id + "/analysis.jpg"
	]
	
	for i in range(min(case_images.size(), images.size())):
		var image_path = case_images[i]
		if FileAccess.file_exists(image_path):
			images[i].load_image_from_path(image_path)
			print("📂 Loaded case image: ", image_path)
		else:
			print("⚠️ Case image not found: ", image_path)
