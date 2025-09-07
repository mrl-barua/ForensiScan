# Debug script for ZoomableImage centering issue

extends Control

func _ready():
	print("🔍 Debug: ZoomableImage centering test")
	test_modal_positioning()

func test_modal_positioning():
	var zoomable = get_node("ZoomableImage")
	if not zoomable:
		print("❌ ZoomableImage not found")
		return
	
	print("✅ ZoomableImage found")
	
	# Check initial positioning
	print("📍 ZoomableImage position: ", zoomable.position)
	print("📐 ZoomableImage size: ", zoomable.size)
	print("🖥️ Viewport size: ", get_viewport().get_visible_rect().size)
	
	# Connect to the image click signal to debug modal opening
	if zoomable.has_signal("image_clicked"):
		zoomable.image_clicked.connect(_on_image_clicked)
		print("✅ Connected to image_clicked signal")

func _on_image_clicked():
	print("🖱️ Image clicked - modal should be opening...")
	
	var zoomable = get_node("ZoomableImage")
	if zoomable:
		# Check modal positioning after it opens
		call_deferred("check_modal_position", zoomable)

func check_modal_position(zoomable):
	print("🔍 Checking modal position...")
	
	var overlay = zoomable.get_node("FullScreenOverlay")
	if overlay:
		print("📍 FullScreenOverlay position: ", overlay.position)
		print("📐 FullScreenOverlay size: ", overlay.size)
		print("⚓ FullScreenOverlay anchors: L:", overlay.anchor_left, " T:", overlay.anchor_top, " R:", overlay.anchor_right, " B:", overlay.anchor_bottom)
		
		var modal = overlay.get_node("ModalWindow")
		if modal:
			print("📍 ModalWindow position: ", modal.position)
			print("📐 ModalWindow size: ", modal.size)
			print("⚓ ModalWindow anchors: L:", modal.anchor_left, " T:", modal.anchor_top, " R:", modal.anchor_right, " B:", modal.anchor_bottom)
		else:
			print("❌ ModalWindow not found")
	else:
		print("❌ FullScreenOverlay not found")
