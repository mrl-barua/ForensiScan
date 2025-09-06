# ZoomableImage Integration Examples for Godot 4.2

extends Control

# Example of how to use ZoomableImage component in your scenes

# Reference to the ZoomableImage component
@onready var fingerprint_viewer: Control
@onready var certificate_viewer: Control
@onready var diagram_viewer: Control

func _ready():
	setup_zoomable_images()
	connect_image_signals()

# Example 1: Basic Setup
func setup_zoomable_images():
	print("Setting up ZoomableImage components...")
	
	# Create a zoomable image for fingerprint analysis
	create_fingerprint_viewer()
	
	# Create a zoomable image for certificate viewing
	create_certificate_viewer()
	
	# Create a zoomable image for technical diagrams
	create_diagram_viewer()

# Example 2: Dynamic Creation
func create_fingerprint_viewer():
	var zoomable_scene = preload("res://src/scenes/Components/ZoomableImage.tscn")
	fingerprint_viewer = zoomable_scene.instantiate()
	
	# Configure for fingerprint analysis
	fingerprint_viewer.image_texture = preload("res://assets/images/Lesson/Fingerpint_Sample_1.jpg")
	fingerprint_viewer.image_size = Vector2(300, 200)
	fingerprint_viewer.label_text = "Click to analyze fingerprint"
	fingerprint_viewer.modal_window_size = Vector2(1000, 700)
	fingerprint_viewer.zoom_speed = 0.15  # Slower zoom for detailed analysis
	fingerprint_viewer.max_zoom = 12.0    # Higher zoom for forensic details
	
	# Position in top-right corner
	fingerprint_viewer.anchors_preset = Control.PRESET_TOP_RIGHT
	fingerprint_viewer.position = Vector2(-320, 20)
	
	add_child(fingerprint_viewer)
	print("✅ Fingerprint viewer created")

# Example 3: Certificate Viewer
func create_certificate_viewer():
	var zoomable_scene = preload("res://src/scenes/Components/ZoomableImage.tscn")
	certificate_viewer = zoomable_scene.instantiate()
	
	# Configure for certificate viewing
	if ResourceLoader.exists("res://assets/images/certificates/license.png"):
		certificate_viewer.image_texture = load("res://assets/images/certificates/license.png")
	certificate_viewer.image_size = Vector2(200, 280)
	certificate_viewer.label_text = "View Certificate"
	certificate_viewer.modal_window_size = Vector2(800, 900)
	
	# Position in bottom-left corner
	certificate_viewer.anchors_preset = Control.PRESET_BOTTOM_LEFT
	certificate_viewer.position = Vector2(20, -300)
	
	add_child(certificate_viewer)
	print("✅ Certificate viewer created")

# Example 4: Technical Diagram Viewer
func create_diagram_viewer():
	var zoomable_scene = preload("res://src/scenes/Components/ZoomableImage.tscn")
	diagram_viewer = zoomable_scene.instantiate()
	
	# Configure for technical diagrams
	diagram_viewer.image_size = Vector2(250, 180)
	diagram_viewer.label_text = "View Diagram"
	diagram_viewer.modal_window_size = Vector2(900, 650)
	diagram_viewer.enable_haptic_feedback = true
	
	# Position centered
	diagram_viewer.anchors_preset = Control.PRESET_CENTER
	diagram_viewer.position = Vector2(-125, -90)
	
	add_child(diagram_viewer)
	print("✅ Diagram viewer created")

# Example 5: Signal Connections
func connect_image_signals():
	# Connect to fingerprint viewer signals
	if fingerprint_viewer:
		fingerprint_viewer.image_clicked.connect(_on_fingerprint_clicked)
		fingerprint_viewer.fullscreen_opened.connect(_on_modal_opened.bind("Fingerprint Analysis"))
		fingerprint_viewer.fullscreen_closed.connect(_on_modal_closed)
	
	# Connect to certificate viewer signals
	if certificate_viewer:
		certificate_viewer.image_clicked.connect(_on_certificate_clicked)
		certificate_viewer.fullscreen_opened.connect(_on_modal_opened.bind("Certificate Viewer"))
		certificate_viewer.fullscreen_closed.connect(_on_modal_closed)
	
	# Connect to diagram viewer signals
	if diagram_viewer:
		diagram_viewer.image_clicked.connect(_on_diagram_clicked)
		diagram_viewer.fullscreen_opened.connect(_on_modal_opened.bind("Technical Diagram"))
		diagram_viewer.fullscreen_closed.connect(_on_modal_closed)

# Example 6: Event Handlers
func _on_fingerprint_clicked():
	print("🔍 Fingerprint image clicked - opening analysis view")
	# You can add custom logic here, like:
	# - Start analysis timer
	# - Show analysis tools
	# - Record user interaction

func _on_certificate_clicked():
	print("📜 Certificate image clicked - opening certificate viewer")
	# Custom logic for certificate viewing:
	# - Validate certificate
	# - Show certificate details
	# - Log access

func _on_diagram_clicked():
	print("📊 Diagram image clicked - opening technical view")
	# Custom logic for diagrams:
	# - Load related data
	# - Show measurement tools
	# - Enable annotations

func _on_modal_opened(viewer_type: String):
	print("🔍 Modal opened: ", viewer_type)
	# Global modal logic:
	# - Pause background processes
	# - Dim other UI elements
	# - Start modal usage timer

func _on_modal_closed():
	print("❌ Modal closed")
	# Global cleanup logic:
	# - Resume background processes
	# - Restore UI brightness
	# - Save user preferences

# Example 7: Dynamic Image Loading
func load_image_dynamically(viewer: Control, image_path: String):
	if ResourceLoader.exists(image_path):
		var texture = load(image_path)
		viewer.set_image_texture(texture)
		print("✅ Loaded image: ", image_path)
	else:
		print("❌ Image not found: ", image_path)

# Example 8: Responsive Sizing
func adjust_for_mobile():
	if OS.get_name() == "Android":
		# Adjust sizes for mobile
		if fingerprint_viewer:
			fingerprint_viewer.image_size = Vector2(200, 130)
			fingerprint_viewer.modal_window_size = Vector2(get_viewport().size.x - 40, get_viewport().size.y - 80)
		
		if certificate_viewer:
			certificate_viewer.image_size = Vector2(150, 210)
		
		if diagram_viewer:
			diagram_viewer.image_size = Vector2(180, 130)

# Example 9: Batch Configuration
func configure_all_viewers_for_lesson(lesson_type: String):
	var config = get_lesson_config(lesson_type)
	
	var viewers = [fingerprint_viewer, certificate_viewer, diagram_viewer]
	for viewer in viewers:
		if viewer:
			viewer.zoom_speed = config.zoom_speed
			viewer.modal_window_size = config.modal_size
			viewer.enable_haptic_feedback = config.haptic_enabled

func get_lesson_config(lesson_type: String) -> Dictionary:
	var configs = {
		"forensics": {
			"zoom_speed": 0.1,
			"modal_size": Vector2(1200, 800),
			"haptic_enabled": true
		},
		"theory": {
			"zoom_speed": 0.2,
			"modal_size": Vector2(900, 600),
			"haptic_enabled": false
		}
	}
	
	return configs.get(lesson_type, configs["theory"])

# Example 10: Performance Optimization
func _on_scene_changed():
	# Clean up when changing scenes
	var viewers = [fingerprint_viewer, certificate_viewer, diagram_viewer]
	for viewer in viewers:
		if viewer and viewer.is_modal_open:
			viewer._on_close_button_pressed()  # Close any open modals

func _exit_tree():
	# Ensure proper cleanup
	_on_scene_changed()
