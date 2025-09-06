extends Control

# Simple test scene to verify ZoomableImage component works

@onready var test_image: Control

func _ready():
	create_test_image()

func create_test_image():
	print("Creating test zoomable image...")
	
	# Load the ZoomableImage scene
	var zoomable_scene = preload("res://src/scenes/Components/ZoomableImage.tscn")
	test_image = zoomable_scene.instantiate()
	
	# Load a test texture
	var texture = load("res://assets/images/Lesson/Fingerpint_Sample_1.jpg") as Texture2D
	
	if texture:
		print("Texture loaded successfully: ", texture.get_size())
		
		# Configure the image
		test_image.set_image_texture(texture, Vector2(300, 200))
		test_image.set_label_text("Test fingerprint - click to zoom")
		test_image.set_return_callback(_on_test_return)
		
		# Connect signals for debugging
		test_image.image_clicked.connect(_on_test_image_clicked)
		test_image.fullscreen_opened.connect(_on_test_fullscreen_opened)
		test_image.fullscreen_closed.connect(_on_test_fullscreen_closed)
		
		# Add to scene
		add_child(test_image)
		
		# Position it in the center
		test_image.position = Vector2(200, 100)
		test_image.size = Vector2(400, 350)
		
		print("Test image created successfully")
	else:
		print("ERROR: Failed to load texture")

func _on_test_image_clicked():
	print("✅ Image clicked successfully - opening fullscreen")

func _on_test_fullscreen_opened():
	print("✅ Fullscreen opened successfully")

func _on_test_fullscreen_closed():
	print("✅ Fullscreen closed successfully")

func _on_test_return():
	print("✅ Return callback called successfully")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_T:
			print("Testing manual fullscreen open...")
			if test_image:
				test_image.open_fullscreen()
		elif event.keycode == KEY_Q:
			print("Quitting test...")
			get_tree().quit()
