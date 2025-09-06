extends Control

# Configurable properties
@export var image_texture: Texture2D
@export var image_size: Vector2 = Vector2(400, 300)
@export var zoom_speed: float = 0.2
@export var min_zoom: float = 0.5
@export var max_zoom: float = 5.0
@export var label_text: String = "Click to zoom"

# Node references
@onready var image_container: Control = $ImageContainer
@onready var image_button: TextureButton = $ImageContainer/ImageButton
@onready var image_label: Label = $ImageContainer/ImageLabel
@onready var fullscreen_overlay: Control = $FullScreenOverlay
@onready var close_button: Button = $FullScreenOverlay/CloseButton
@onready var zoom_out_button: Button = $FullScreenOverlay/ZoomControls/ZoomOutButton
@onready var zoom_in_button: Button = $FullScreenOverlay/ZoomControls/ZoomInButton
@onready var reset_zoom_button: Button = $FullScreenOverlay/ZoomControls/ResetZoomButton
@onready var zoom_info: Label = $FullScreenOverlay/ZoomInfo
@onready var scroll_container: ScrollContainer = $FullScreenOverlay/ScrollContainer
@onready var fullscreen_image: TextureRect = $FullScreenOverlay/ScrollContainer/FullScreenImage

# Zoom and pan variables
var current_zoom: float = 1.0
var dragging: bool = false
var last_mouse_pos: Vector2
var touches := {}
var previous_distance := 0.0
var original_image_size: Vector2

# Navigation state
var previous_scene_path: String = ""
var return_callback: Callable

# Signals
signal image_clicked
signal fullscreen_opened
signal fullscreen_closed

func _ready():
	setup_component()
	connect_signals()

func setup_component():
	# Setup image button
	if image_texture:
		set_image_texture(image_texture)
	
	# Setup label
	image_label.text = label_text
	
	# Configure scroll container
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO

func connect_signals():
	# Connect button signals (already connected in scene, but ensuring they exist)
	if not image_button.pressed.is_connected(_on_image_clicked):
		image_button.pressed.connect(_on_image_clicked)
	if not close_button.pressed.is_connected(_on_close_button_pressed):
		close_button.pressed.connect(_on_close_button_pressed)
	if not zoom_out_button.pressed.is_connected(_on_zoom_out_pressed):
		zoom_out_button.pressed.connect(_on_zoom_out_pressed)
	if not zoom_in_button.pressed.is_connected(_on_zoom_in_pressed):
		zoom_in_button.pressed.connect(_on_zoom_in_pressed)
	if not reset_zoom_button.pressed.is_connected(_on_reset_zoom_pressed):
		reset_zoom_button.pressed.connect(_on_reset_zoom_pressed)

# Public method to set image from code
func set_image_texture(texture: Texture2D, new_size: Vector2 = Vector2.ZERO):
	image_texture = texture
	
	if texture:
		# Set for preview button
		image_button.texture_normal = texture
		
		# Set for fullscreen view
		fullscreen_image.texture = texture
		
		# Store original size
		original_image_size = texture.get_size()
		
		# Resize the preview image button
		if new_size != Vector2.ZERO:
			image_size = new_size
		
		image_button.custom_minimum_size = image_size
		image_button.size = image_size
		
		# Center the image button
		var container_size = image_container.size
		if container_size == Vector2.ZERO:
			container_size = Vector2(800, 600)  # Default fallback
		
		image_button.position = (container_size - image_size) / 2

# Public method to set label text
func set_label_text(text: String):
	label_text = text
	if image_label:
		image_label.text = text

# Public method to set return callback for navigation
func set_return_callback(callback: Callable):
	return_callback = callback

# Handle image click to open fullscreen
func _on_image_clicked():
	print("Image clicked - opening fullscreen view")
	open_fullscreen()
	image_clicked.emit()

# Open fullscreen view
func open_fullscreen():
	if not image_texture:
		print("Warning: No image texture set for fullscreen view")
		return
	
	# Reset zoom
	current_zoom = 1.0
	update_zoom_display()
	
	# Show fullscreen overlay
	fullscreen_overlay.visible = true
	fullscreen_overlay.z_index = 100  # Ensure it's on top
	
	# Reset image size and position
	reset_fullscreen_image()
	
	# Emit signal
	fullscreen_opened.emit()
	
	print("Fullscreen view opened")

# Close fullscreen view
func close_fullscreen():
	fullscreen_overlay.visible = false
	
	# Call return callback if set
	if return_callback.is_valid():
		return_callback.call()
	
	# Emit signal
	fullscreen_closed.emit()
	
	print("Fullscreen view closed")

# Reset fullscreen image to fit container
func reset_fullscreen_image():
	if not image_texture:
		return
	
	var container_size = scroll_container.size
	var texture_size = original_image_size
	
	# Calculate scale to fit image in container while maintaining aspect ratio
	var scale_x = container_size.x / texture_size.x
	var scale_y = container_size.y / texture_size.y
	var fit_scale = min(scale_x, scale_y) * 0.9  # 90% to leave some margin
	
	current_zoom = fit_scale
	apply_zoom_to_image()

# Apply current zoom to fullscreen image
func apply_zoom_to_image():
	if not image_texture:
		return
	
	var new_size = original_image_size * current_zoom
	fullscreen_image.custom_minimum_size = new_size
	fullscreen_image.size = new_size
	
	# Update zoom display
	update_zoom_display()

# Update zoom percentage display
func update_zoom_display():
	var zoom_percentage = int(current_zoom * 100)
	zoom_info.text = "Zoom: " + str(zoom_percentage) + "%"

# Handle fullscreen input events
func _gui_input(event):
	if not fullscreen_overlay.visible:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				last_mouse_pos = event.position
			else:
				dragging = false
	elif event is InputEventMouseMotion and dragging:
		var delta = last_mouse_pos - event.position
		scroll_container.scroll_horizontal += delta.x
		scroll_container.scroll_vertical += delta.y
		last_mouse_pos = event.position
	elif event is InputEventScreenTouch:
		if event.pressed:
			touches[event.index] = event.position
		else:
			touches.erase(event.index)
			previous_distance = 0.0
	elif event is InputEventScreenDrag:
		touches[event.index] = event.position
		if touches.size() == 2:
			# Pinch to zoom
			var touch_points = touches.values()
			var current_distance = touch_points[0].distance_to(touch_points[1])
			if previous_distance > 0:
				var zoom_factor = current_distance / previous_distance
				var new_zoom = current_zoom * zoom_factor
				set_zoom(new_zoom)
			previous_distance = current_distance
		elif touches.size() == 1:
			# Pan with single touch
			var delta = event.relative
			scroll_container.scroll_horizontal -= delta.x
			scroll_container.scroll_vertical -= delta.y

# Zoom in
func zoom_in():
	var new_zoom = current_zoom + zoom_speed
	set_zoom(new_zoom)

# Zoom out
func zoom_out():
	var new_zoom = current_zoom - zoom_speed
	set_zoom(new_zoom)

# Set specific zoom level
func set_zoom(zoom_level: float):
	current_zoom = clamp(zoom_level, min_zoom, max_zoom)
	apply_zoom_to_image()

# Reset zoom to fit container
func reset_zoom():
	reset_fullscreen_image()

# Button event handlers
func _on_close_button_pressed():
	close_fullscreen()

func _on_zoom_in_pressed():
	zoom_in()

func _on_zoom_out_pressed():
	zoom_out()

func _on_reset_zoom_pressed():
	reset_zoom()

# Handle escape key to close fullscreen
func _input(event):
	if fullscreen_overlay.visible and event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			close_fullscreen()

# Utility function to load image from file path
func load_image_from_path(path: String) -> bool:
	var texture = load(path) as Texture2D
	if texture:
		set_image_texture(texture)
		return true
	else:
		print("Failed to load image from: " + path)
		return false

# Utility function to set custom size
func set_preview_size(new_size: Vector2):
	image_size = new_size
	if image_button:
		image_button.custom_minimum_size = image_size
		image_button.size = image_size
		
		# Re-center the button
		var container_size = image_container.size
		if container_size != Vector2.ZERO:
			image_button.position = (container_size - image_size) / 2
