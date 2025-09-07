# Android Modal Size Test Script

extends Control

func _ready():
	print("📱 Testing Android modal sizing...")
	test_android_modal_sizes()

func test_android_modal_sizes():
	# Simulate different Android screen sizes
	var test_sizes = [
		{"name": "Phone Portrait", "size": Vector2(360, 640)},
		{"name": "Phone Landscape", "size": Vector2(640, 360)},
		{"name": "Tablet Portrait", "size": Vector2(768, 1024)},
		{"name": "Tablet Landscape", "size": Vector2(1024, 768)}
	]
	
	for test in test_sizes:
		print("\n🔍 Testing: ", test.name, " (", test.size, ")")
		calculate_modal_size_for_screen(test.size)

func calculate_modal_size_for_screen(screen_size: Vector2):
	var padding = 40
	var android_size = screen_size - Vector2(padding, padding)
	
	var scale_sizes = {
		"Small (70%)": screen_size * 0.7,
		"Medium (85%)": screen_size * 0.85,
		"Large (95%)": screen_size * 0.95
	}
	
	print("  📐 Fullscreen mode: ", android_size)
	for mode in scale_sizes:
		print("  📐 ", mode, ": ", scale_sizes[mode])
	
	# Calculate how much more screen space is used
	var old_size = Vector2(800, 600)  # Old default size
	var improvement = (android_size.x * android_size.y) / (old_size.x * old_size.y)
	print("  📊 Screen usage improvement: ", "%.1f" % improvement, "x better")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_T:
			test_android_modal_sizes()
