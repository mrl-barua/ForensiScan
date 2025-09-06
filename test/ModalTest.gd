# ZoomableImage Modal Test Script

extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	print("🧪 ZoomableImage Modal Test - Ready")
	test_modal_functionality()

func test_modal_functionality():
	print("📋 Testing ZoomableImage modal functionality...")
	
	# Find the ZoomableImage component
	var zoomable_image = get_node("ZoomableImageModal")
	if not zoomable_image:
		print("❌ ZoomableImage component not found!")
		return
	
	print("✅ ZoomableImage component found")
	
	# Test basic properties
	print("🔍 Testing basic properties...")
	print("   Image size: ", zoomable_image.image_size)
	print("   Modal window size: ", zoomable_image.modal_window_size)
	print("   Modal min size: ", zoomable_image.modal_min_size)
	print("   Modal max size: ", zoomable_image.modal_max_size)
	
	# Test component initialization
	print("🔧 Testing component initialization...")
	zoomable_image._ready()
	
	# Test if nodes are properly connected
	print("🔗 Testing node connections...")
	if zoomable_image.image_button:
		print("   ✅ Image button found")
	else:
		print("   ❌ Image button not found")
	
	if zoomable_image.modal_window:
		print("   ✅ Modal window found")
	else:
		print("   ❌ Modal window not found")
	
	if zoomable_image.resize_handle:
		print("   ✅ Resize handle found")
	else:
		print("   ❌ Resize handle not found")
	
	if zoomable_image.title_bar_drag_area:
		print("   ✅ Title bar drag area found")
	else:
		print("   ❌ Title bar drag area not found")
	
	print("🎯 Modal test completed!")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_T:
			print("🔧 Running manual test...")
			test_modal_open_close()
		elif event.keycode == KEY_R:
			print("🔄 Resetting test...")
			get_tree().reload_current_scene()

func test_modal_open_close():
	var zoomable_image = get_node("ZoomableImageModal")
	if zoomable_image:
		print("📋 Testing modal open/close...")
		if not zoomable_image.is_modal_open:
			print("   Opening modal...")
			zoomable_image._on_image_clicked()
		else:
			print("   Closing modal...")
			zoomable_image._on_close_button_pressed()
	else:
		print("❌ ZoomableImage not found for test")
