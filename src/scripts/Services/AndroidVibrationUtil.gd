# Android Vibration Utility for ZoomableImage Component
# This provides haptic feedback functionality for Android devices

class_name AndroidVibrationUtil

static var vibration_singleton = null
static var is_initialized = false

# Initialize the vibration system
static func initialize():
	if is_initialized:
		return true
		
	if OS.get_name() == "Android":
		# Try to get Android vibration singleton
		if Engine.has_singleton("AndroidVibration"):
			vibration_singleton = Engine.get_singleton("AndroidVibration")
			is_initialized = true
			print("✅ Android vibration initialized")
			return true
		else:
			# Fallback to basic input vibration
			vibration_singleton = Input
			is_initialized = true
			print("⚠️ Using fallback vibration system")
			return true
	
	print("ℹ️ Vibration not available on this platform")
	return false

# Trigger light haptic feedback (for UI interactions)
static func light_feedback():
	if not initialize():
		return
		
	if vibration_singleton and OS.get_name() == "Android":
		if vibration_singleton.has_method("vibrate"):
			vibration_singleton.vibrate(30)  # 30ms light vibration
		elif vibration_singleton.has_method("start_joy_vibration"):
			# Fallback for Input singleton
			vibration_singleton.start_joy_vibration(0, 0.3, 0.3, 0.03)

# Trigger medium haptic feedback (for important actions)
static func medium_feedback():
	if not initialize():
		return
		
	if vibration_singleton and OS.get_name() == "Android":
		if vibration_singleton.has_method("vibrate"):
			vibration_singleton.vibrate(50)  # 50ms medium vibration
		elif vibration_singleton.has_method("start_joy_vibration"):
			vibration_singleton.start_joy_vibration(0, 0.5, 0.5, 0.05)

# Trigger strong haptic feedback (for major events)
static func strong_feedback():
	if not initialize():
		return
		
	if vibration_singleton and OS.get_name() == "Android":
		if vibration_singleton.has_method("vibrate"):
			vibration_singleton.vibrate(100)  # 100ms strong vibration
		elif vibration_singleton.has_method("start_joy_vibration"):
			vibration_singleton.start_joy_vibration(0, 0.8, 0.8, 0.1)

# Custom vibration pattern
static func pattern_vibration(pattern: Array[int]):
	if not initialize():
		return
		
	if vibration_singleton and OS.get_name() == "Android":
		if vibration_singleton.has_method("vibrate_pattern"):
			vibration_singleton.vibrate_pattern(pattern)
		else:
			# Simulate pattern with individual vibrations
			for duration in pattern:
				if duration > 0:
					vibration_singleton.vibrate(duration)
				await Engine.get_main_loop().create_timer(duration / 1000.0).timeout

# Check if vibration is supported
static func is_vibration_supported() -> bool:
	return initialize() and vibration_singleton != null
