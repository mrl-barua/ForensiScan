extends SceneTree

func _init():
	# Test loading the MainMenu scene
	print("Testing MainMenu scene loading...")
	
	var scene = load("res://src/scenes/MainMenu.tscn")
	if scene:
		print("✅ MainMenu.tscn loaded successfully!")
		var instance = scene.instantiate()
		if instance:
			print("✅ MainMenu scene instantiated successfully!")
			instance.free()
		else:
			print("❌ Failed to instantiate MainMenu scene")
	else:
		print("❌ Failed to load MainMenu.tscn")
	
	quit()
