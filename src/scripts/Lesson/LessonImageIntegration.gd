extends Control

# Example of integrating ZoomableImage into an existing lesson
# This shows how to add image examination to a forensic science lesson

@onready var lesson_content: VBoxContainer = $LessonContent
@onready var navigation_controls = $NavigationControls
@onready var progress_manager = ProgressManager

# Create zoomable images for the lesson
func _ready():
	setup_lesson_images()
	connect_image_signals()

func setup_lesson_images():
	# Example: Fingerprint analysis lesson
	var fingerprint_section = create_image_section(
		"res://assets/images/Lesson/Fingerpint_Sample_1.jpg",
		"Examine this fingerprint sample",
		"Look for ridge patterns, minutiae points, and classification features"
	)
	lesson_content.add_child(fingerprint_section)
	
	# Example: Evidence photo
	var evidence_section = create_image_section(
		"res://assets/images/Lesson/prelim_1.10.png", 
		"Crime scene evidence",
		"Analyze this piece of evidence found at the scene"
	)
	lesson_content.add_child(evidence_section)

func create_image_section(image_path: String, title: String, description: String) -> VBoxContainer:
	var section = VBoxContainer.new()
	
	# Title
	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 24)
	section.add_child(title_label)
	
	# Description
	var desc_label = Label.new()
	desc_label.text = description
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	section.add_child(desc_label)
	
	# Zoomable Image
	var zoomable_scene = preload("res://src/scenes/Components/ZoomableImage.tscn")
	var zoomable_image = zoomable_scene.instantiate()
	
	# Load and configure image
	if zoomable_image.load_image_from_path(image_path):
		zoomable_image.set_preview_size(Vector2(400, 300))
		zoomable_image.set_label_text("Click to examine in detail")
		zoomable_image.set_return_callback(_on_return_to_lesson)
		
		# Connect to track user interaction
		zoomable_image.image_clicked.connect(_on_evidence_examined.bind(title))
		zoomable_image.fullscreen_opened.connect(_on_fullscreen_opened)
		zoomable_image.fullscreen_closed.connect(_on_fullscreen_closed)
		
		section.add_child(zoomable_image)
	
	return section

func connect_image_signals():
	# Additional setup if needed
	pass

# Track when user examines evidence
func _on_evidence_examined(evidence_name: String):
	print("Student examined: " + evidence_name)
	progress_manager.mark_activity_completed("examined_" + evidence_name.to_lower().replace(" ", "_"))
	
	# You could also:
	# - Show additional information
	# - Unlock next section
	# - Award points
	# - Track time spent examining

# Handle fullscreen mode
func _on_fullscreen_opened():
	# Hide lesson navigation while examining image
	if navigation_controls:
		navigation_controls.visible = false

func _on_fullscreen_closed():
	# Restore lesson navigation
	if navigation_controls:
		navigation_controls.visible = true

# Handle return from image examination
func _on_return_to_lesson():
	print("Student returned to lesson - can continue from where they left off")
	
	# You could:
	# - Highlight next section
	# - Show related questions
	# - Update lesson progress
	# - Resume any paused media

# Example of programmatically triggering image view
func show_specific_evidence(evidence_id: String):
	# Find the zoomable image component
	var zoomable_images = get_tree().get_nodes_in_group("lesson_images")
	for image_component in zoomable_images:
		if image_component.name == evidence_id:
			image_component.open_fullscreen()
			break
