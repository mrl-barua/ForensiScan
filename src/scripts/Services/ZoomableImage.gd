extends Control

# Configurable properties
@export var image_texture: Texture2D
@export var image_size: Vector2 = Vector2(400, 300)
@export var zoom_speed: float = 0.2
@export var min_zoom: float = 0.3
@export var max_zoom: float = 8.0
@export var label_text: String = "Click to zoom"
@export var enable_haptic_feedback: bool = true
@export var modal_transition_duration: float = 0.3

# Node references
@onready var image_container: Control = $ImageContainer
@onready var image_button: TextureButton = $ImageContainer/ImageButton
@onready var image_label: Label = $ImageContainer/ImageLabel
@onready var fullscreen_overlay: Control = $FullScreenOverlay
@onready var modal_background: ColorRect = $FullScreenOverlay/ModalBackground
@onready var safe_area: Control = $FullScreenOverlay/SafeArea
@onready var top_bar: Panel = $FullScreenOverlay/SafeArea/TopBar
@onready var close_button: Button = $FullScreenOverlay/SafeArea/TopBar/CloseButton
@onready var title_label: Label = $FullScreenOverlay/SafeArea/TopBar/Title
@onready var bottom_bar: Panel = $FullScreenOverlay/SafeArea/BottomBar
@onready var zoom_out_button: Button = $FullScreenOverlay/SafeArea/BottomBar/ZoomControls/ZoomOutButton
@onready var zoom_in_button: Button = $FullScreenOverlay/SafeArea/BottomBar/ZoomControls/ZoomInButton
@onready var reset_zoom_button: Button = $FullScreenOverlay/SafeArea/BottomBar/ResetZoomButton
@onready var zoom_info: Label = $FullScreenOverlay/SafeArea/BottomBar/ZoomControls/ZoomInfo
@onready var scroll_container: ScrollContainer = $FullScreenOverlay/SafeArea/ScrollContainer
@onready var fullscreen_image: TextureRect = $FullScreenOverlay/SafeArea/ScrollContainer/FullScreenImage

# Zoom and pan variables
var current_zoom: float = 1.0
var dragging: bool = false
var last_mouse_pos: Vector2
var touches := {}
var previous_distance := 0.0
var original_image_size: Vector2
var is_panning: bool = false
var pan_threshold: float = 20.0  # Minimum distance to start panning
var initial_touch_pos: Vector2
var double_tap_timer: float = 0.0
var double_tap_threshold: float = 0.3

# Modal state
var is_modal_open: bool = false
var modal_tween: Tween
var previous_modulate: Color
var was_mouse_captured: bool = false

# Navigation state
var previous_scene_path: String = ""
var return_callback: Callable

# Signals
signal image_clicked
signal fullscreen_opened
signal fullscreen_closed

func _ready():
	print("ZoomableImage _ready() called")
	setup_component()
	connect_signals()
	# Call deferred to ensure layout is calculated
	call_deferred("_update_layout")

func _update_layout():
	print("ZoomableImage _update_layout() called")
	# Update the image button position after layout is calculated
	if image_texture and image_button:
		update_image_button_position()
		print("Image button updated - size: ", image_button.size, " position: ", image_button.position)

func setup_component():
	print("ZoomableImage setup_component() called")
	print("Image texture: ", image_texture)
	print("Image size: ", image_size)
	
	# Setup image button
	if image_texture:
		set_image_texture(image_texture)
	
	# Setup label
	if image_label:
		image_label.text = label_text
		print("Label text set to: ", label_text)
	
	# Configure scroll container
	if scroll_container:
		scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO

func connect_signals():
	print("ZoomableImage connect_signals() called")
	
	# Connect button signals (already connected in scene, but ensuring they exist)
	if image_button:
		if not image_button.pressed.is_connected(_on_image_clicked):
			image_button.pressed.connect(_on_image_clicked)
			print("✅ Connected image_button.pressed signal")
		else:
			print("ℹ️ image_button.pressed signal already connected")
	else:
		print("❌ image_button is null!")
		
	if close_button:
		if not close_button.pressed.is_connected(_on_close_button_pressed):
			close_button.pressed.connect(_on_close_button_pressed)
			print("✅ Connected close_button.pressed signal")
	else:
		print("❌ close_button is null!")
		
	if zoom_out_button:
		if not zoom_out_button.pressed.is_connected(_on_zoom_out_pressed):
			zoom_out_button.pressed.connect(_on_zoom_out_pressed)
			print("✅ Connected zoom_out_button.pressed signal")
	else:
		print("❌ zoom_out_button is null!")
		
	if zoom_in_button:
		if not zoom_in_button.pressed.is_connected(_on_zoom_in_pressed):
			zoom_in_button.pressed.connect(_on_zoom_in_pressed)
			print("✅ Connected zoom_in_button.pressed signal")
	else:
		print("❌ zoom_in_button is null!")
		
	if reset_zoom_button:
		if not reset_zoom_button.pressed.is_connected(_on_reset_zoom_pressed):
			reset_zoom_button.pressed.connect(_on_reset_zoom_pressed)
			print("✅ Connected reset_zoom_button.pressed signal")
	else:
		print("❌ reset_zoom_button is null!")

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
		
		# Update position
		update_image_button_position()

# Update image button position 
func update_image_button_position():
	if not image_button or not image_container:
		return
		
	# Use the anchors to center instead of manual positioning
	image_button.anchor_left = 0.5
	image_button.anchor_top = 0.5
	image_button.anchor_right = 0.5
	image_button.anchor_bottom = 0.5
	image_button.offset_left = -image_size.x / 2
	image_button.offset_top = -image_size.y / 2
	image_button.offset_right = image_size.x / 2
	image_button.offset_bottom = image_size.y / 2

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
	print("🖱️ _on_image_clicked() called - opening modal fullscreen view")
	
	# Haptic feedback for mobile
	if enable_haptic_feedback and OS.get_name() == "Android":
		trigger_haptic_feedback()
	
	open_fullscreen_modal()
	image_clicked.emit()
	print("✅ Image clicked signal emitted")

# Open fullscreen view with modal transition
func open_fullscreen_modal():
	print("🔍 open_fullscreen_modal() called")
	if not image_texture:
		print("❌ Warning: No image texture set for fullscreen view")
		return
	
	if is_modal_open:
		return
		
	print("🚀 Opening modal fullscreen view - texture size: ", image_texture.get_size())
	is_modal_open = true
	
	# Reset zoom
	current_zoom = 1.0
	update_zoom_display()
	
	# Show fullscreen overlay
	fullscreen_overlay.visible = true
	fullscreen_overlay.z_index = 1000  # Ensure it's on top
	print("Fullscreen overlay made visible")
	
	# Set initial opacity for animation
	fullscreen_overlay.modulate.a = 0.0
	
	# Reset image size and position
	reset_fullscreen_image()
	
	# Animate modal appearance
	animate_modal_in()
	
	# Capture mouse for desktop testing
	if OS.get_name() != "Android":
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		was_mouse_captured = true
	
	# Set title
	if title_label:
		title_label.text = label_text if label_text != "Click to zoom" else "Image Viewer"
	
	# Emit signal
	fullscreen_opened.emit()
	
	print("Modal fullscreen view opened")

# Close fullscreen view with modal transition
func close_fullscreen_modal():
	if not is_modal_open:
		return
		
	print("🔒 Closing modal fullscreen view")
	
	# Haptic feedback for mobile
	if enable_haptic_feedback and OS.get_name() == "Android":
		trigger_haptic_feedback()
	
	# Animate modal disappearance
	animate_modal_out()
	
	# Restore mouse mode
	if was_mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		was_mouse_captured = false
	
	# Call return callback if set
	if return_callback.is_valid():
		return_callback.call()
	
	# Emit signal
	fullscreen_closed.emit()
	
	print("Modal fullscreen view closed")

# Legacy function for backward compatibility
func open_fullscreen():
	open_fullscreen_modal()

# Public method to open modal programmatically
func open_modal():
	open_fullscreen_modal()

# Public method to close modal programmatically  
func close_modal():
	close_fullscreen_modal()

# Close fullscreen view
func close_fullscreen():
	close_fullscreen_modal()

# Animate modal opening
func animate_modal_in():
	if modal_tween:
		modal_tween.kill()
	
	modal_tween = create_tween()
	modal_tween.set_parallel(true)
	
	# Fade in background
	modal_tween.tween_property(fullscreen_overlay, "modulate:a", 1.0, modal_transition_duration)
	
	# Scale animation for modal feel
	fullscreen_overlay.scale = Vector2(0.8, 0.8)
	modal_tween.tween_property(fullscreen_overlay, "scale", Vector2.ONE, modal_transition_duration)
	modal_tween.tween_property(fullscreen_overlay, "scale", Vector2.ONE, modal_transition_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# Animate modal closing
func animate_modal_out():
	if modal_tween:
		modal_tween.kill()
	
	modal_tween = create_tween()
	modal_tween.set_parallel(true)
	
	# Fade out
	modal_tween.tween_property(fullscreen_overlay, "modulate:a", 0.0, modal_transition_duration)
	
	# Scale down slightly
	modal_tween.tween_property(fullscreen_overlay, "scale", Vector2(0.95, 0.95), modal_transition_duration)
	
	# Hide when animation completes
	modal_tween.tween_callback(func(): 
		fullscreen_overlay.visible = false
		is_modal_open = false
		fullscreen_overlay.scale = Vector2.ONE
	).set_delay(modal_transition_duration)

# Trigger haptic feedback on Android
func trigger_haptic_feedback():
	if OS.get_name() == "Android" and enable_haptic_feedback:
		# Use the AndroidVibrationUtil for better haptic feedback
		AndroidVibrationUtil.light_feedback()

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
	if zoom_info:
		zoom_info.text = str(zoom_percentage) + "%"

# Handle fullscreen input events with enhanced Android support
func _unhandled_input(event):
	if not fullscreen_overlay.visible or not is_modal_open:
		return
	
	# Handle double-tap timer
	if double_tap_timer > 0:
		double_tap_timer -= get_process_delta_time()
	
	if event is InputEventMouseButton:
		handle_mouse_input(event)
	elif event is InputEventMouseMotion and dragging:
		handle_mouse_drag(event)
	elif event is InputEventScreenTouch:
		handle_touch_input(event)
	elif event is InputEventScreenDrag:
		handle_touch_drag(event)
	elif event is InputEventMagnifyGesture:
		handle_magnify_gesture(event)

# Handle mouse input for desktop
func handle_mouse_input(event: InputEventMouseButton):
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		zoom_in()
		get_viewport().set_input_as_handled()
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		zoom_out()
		get_viewport().set_input_as_handled()
	elif event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			last_mouse_pos = event.position
		else:
			dragging = false
		get_viewport().set_input_as_handled()

# Handle mouse drag for desktop
func handle_mouse_drag(event: InputEventMouseMotion):
	var delta = last_mouse_pos - event.position
	scroll_container.scroll_horizontal += delta.x
	scroll_container.scroll_vertical += delta.y
	last_mouse_pos = event.position
	get_viewport().set_input_as_handled()

# Handle touch input for mobile
func handle_touch_input(event: InputEventScreenTouch):
	if event.pressed:
		touches[event.index] = event.position
		
		# Handle double-tap to zoom
		if event.index == 0:  # Primary touch
			if double_tap_timer > 0:
				# Double tap detected
				handle_double_tap(event.position)
				double_tap_timer = 0
			else:
				# Start double-tap timer
				double_tap_timer = double_tap_threshold
				initial_touch_pos = event.position
		
		# Haptic feedback for touch start
		if enable_haptic_feedback:
			trigger_haptic_feedback()
	else:
		touches.erase(event.index)
		previous_distance = 0.0
		is_panning = false
	
	get_viewport().set_input_as_handled()

# Handle touch drag for mobile
func handle_touch_drag(event: InputEventScreenDrag):
	touches[event.index] = event.position
	
	if touches.size() == 2:
		handle_pinch_zoom()
	elif touches.size() == 1 and event.index == 0:
		handle_single_touch_pan(event)
	
	get_viewport().set_input_as_handled()

# Handle pinch-to-zoom gesture
func handle_pinch_zoom():
	var touch_points = touches.values()
	var current_distance = touch_points[0].distance_to(touch_points[1])
	
	if previous_distance > 0:
		var zoom_factor = current_distance / previous_distance
		var new_zoom = current_zoom * zoom_factor
		set_zoom(new_zoom)
		
		# Center zoom between the two touch points
		var zoom_center = (touch_points[0] + touch_points[1]) / 2
		center_zoom_on_point(zoom_center)
	
	previous_distance = current_distance

# Handle single touch pan
func handle_single_touch_pan(event: InputEventScreenDrag):
	# Only start panning if moved beyond threshold
	if not is_panning:
		var distance = initial_touch_pos.distance_to(event.position)
		if distance > pan_threshold:
			is_panning = true
	
	if is_panning:
		var delta = event.relative
		scroll_container.scroll_horizontal -= delta.x
		scroll_container.scroll_vertical -= delta.y

# Handle double-tap to zoom
func handle_double_tap(position: Vector2):
	if current_zoom <= 1.0:
		# Zoom in to 2x at tap position
		set_zoom(2.0)
		center_zoom_on_point(position)
	else:
		# Reset zoom
		reset_zoom()
	
	# Haptic feedback for double-tap
	if enable_haptic_feedback:
		trigger_haptic_feedback()

# Handle magnify gesture (trackpad)
func handle_magnify_gesture(event: InputEventMagnifyGesture):
	var zoom_delta = zoom_speed * (event.factor - 1.0)
	var new_zoom = current_zoom + zoom_delta
	set_zoom(new_zoom)
	get_viewport().set_input_as_handled()

# Center zoom on a specific point
func center_zoom_on_point(point: Vector2):
	# Convert point to scroll container coordinates
	var container_rect = scroll_container.get_rect()
	var relative_point = point - container_rect.position
	
	# Calculate where to scroll to center the zoom on this point
	var scroll_x = (relative_point.x / container_rect.size.x) * (fullscreen_image.size.x - container_rect.size.x)
	var scroll_y = (relative_point.y / container_rect.size.y) * (fullscreen_image.size.y - container_rect.size.y)
	
	scroll_container.scroll_horizontal = max(0, scroll_x)
	scroll_container.scroll_vertical = max(0, scroll_y)

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
		
		# Update position using anchors
		update_image_button_position()
