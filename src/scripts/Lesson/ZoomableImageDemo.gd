extends Control

# Demo script showing how to use the ZoomableImage component

@onready var zoomable_image_1: Control = $GridContainer/ZoomableImage1
@onready var zoomable_image_2: Control = $GridContainer/ZoomableImage2
@onready var zoomable_image_3: Control = $GridContainer/ZoomableImage3
@onready var zoomable_image_4: Control = $GridContainer/ZoomableImage4
@onready var back_button: Button = $BackButton

func _ready():
	setup_zoomable_images()
	connect_signals()

func setup_zoomable_images():
	# Example 1: Basic setup with default settings
	zoomable_image_1.set_label_text("Click to view fingerprint details")
	
	# Example 2: Custom size and settings
	zoomable_image_2.set_preview_size(Vector2(300, 200))
	zoomable_image_2.set_label_text("Enhanced fingerprint view")
	
	# Example 3: Different image if available
	zoomable_image_3.set_label_text("Evidence analysis")
	
	# Example 4: Smaller preview
	zoomable_image_4.set_preview_size(Vector2(250, 180))
	zoomable_image_4.set_label_text("Reference image")
	
	# Set return callbacks for navigation
	zoomable_image_1.set_return_callback(_on_return_from_fullscreen)
	zoomable_image_2.set_return_callback(_on_return_from_fullscreen)
	zoomable_image_3.set_return_callback(_on_return_from_fullscreen)
	zoomable_image_4.set_return_callback(_on_return_from_fullscreen)

func connect_signals():
	# Connect to image events
	zoomable_image_1.image_clicked.connect(_on_image_1_clicked)
	zoomable_image_2.image_clicked.connect(_on_image_2_clicked)
	zoomable_image_3.image_clicked.connect(_on_image_3_clicked)
	zoomable_image_4.image_clicked.connect(_on_image_4_clicked)
	
	zoomable_image_1.fullscreen_opened.connect(_on_fullscreen_opened)
	zoomable_image_1.fullscreen_closed.connect(_on_fullscreen_closed)

# Handle specific image clicks
func _on_image_1_clicked():
	print("Fingerprint Sample 1 clicked - opening detailed view")

func _on_image_2_clicked():
	print("Fingerprint Sample 2 clicked - opening enhanced view")

func _on_image_3_clicked():
	print("Evidence Photo 1 clicked - opening analysis view")

func _on_image_4_clicked():
	print("Analysis Reference clicked - opening reference view")

# Handle fullscreen events
func _on_fullscreen_opened():
	print("Fullscreen view opened - hiding UI elements")
	back_button.visible = false

func _on_fullscreen_closed():
	print("Fullscreen view closed - restoring UI elements")
	back_button.visible = true

# Handle return from fullscreen
func _on_return_from_fullscreen():
	print("Returned from fullscreen - user can continue where they left off")
	# You can add any additional logic here, such as:
	# - Resuming animations
	# - Updating progress tracking
	# - Logging user interaction

# Navigate back to main menu
func _on_back_button_pressed():
	print("Returning to main menu")
	# In a real application, you would navigate to the appropriate scene
	get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn")

# Example of how to dynamically load different images
func load_different_image_example():
	# Load a different image from assets
	var new_texture = load("res://assets/images/Background/fingerprint.png") as Texture2D
	if new_texture:
		zoomable_image_3.set_image_texture(new_texture)
		zoomable_image_3.set_label_text("Background fingerprint")

# Example of how to use the component programmatically
func create_zoomable_image_programmatically():
	# Load the ZoomableImage scene
	var zoomable_scene = preload("res://src/scenes/Components/ZoomableImage.tscn")
	var zoomable_instance = zoomable_scene.instantiate()
	
	# Configure it
	var texture = load("res://assets/images/Lesson/Fingerpint_Sample_1.jpg") as Texture2D
	zoomable_instance.set_image_texture(texture, Vector2(200, 150))
	zoomable_instance.set_label_text("Dynamically created image")
	
	# Set return callback
	zoomable_instance.set_return_callback(_on_return_from_fullscreen)
	
	# Add to scene
	add_child(zoomable_instance)
	
	# Position it
	zoomable_instance.position = Vector2(100, 100)
