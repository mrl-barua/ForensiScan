# LicenseVerifier.gd
extends Control

# ⚠️ This must match the generator's key. 
const SECRET_KEY := "HCDC_PROJECT"
const LICENSE_FILE := "user://license.cfg"

# License Verifier System
# Handles secure license validation with modern UI/UX

# Node references
@onready var license_input: LineEdit = $CanvasLayer/MainContainer/LicensePanel/MainLayout/InputSection/LicenseInput
@onready var validate_button: Button = $CanvasLayer/MainContainer/LicensePanel/MainLayout/ButtonSection/ValidateButton
@onready var help_button: Button = $CanvasLayer/MainContainer/LicensePanel/MainLayout/ButtonSection/HelpButton
@onready var status_message: Label = $CanvasLayer/MainContainer/LicensePanel/MainLayout/HeaderSection/StatusMessage
@onready var loading_spinner: Label = $CanvasLayer/MainContainer/LicensePanel/LoadingSpinner
@onready var main_panel: Panel = $CanvasLayer/MainContainer/LicensePanel

# Animation tweens
var shake_tween: Tween
var fade_tween: Tween
var spinner_tween: Tween

# Constants for messages
const ACTIVATION_EXPIRED_MESSAGE = "Your license has expired. Please contact support for renewal."
const INVALID_LICENSE_MESSAGE = "❌ Invalid license key. Please check and try again."
const VALID_LICENSE_MESSAGE = "✅ License validated successfully! Welcome to ForensiScan."
const PROCESSING_MESSAGE = "🔍 Validating license..."
const ERROR_MESSAGE = "⚠️ Error processing license. Please try again."

signal license_validated
signal license_failed

func _ready():
	# Set initial focus and state
	license_input.grab_focus()
	update_ui_state(false)
	
	# Add smooth entrance animation
	animate_entrance()
	
	# Check if already activated
	if is_activated():
		_on_successful_validation()

func animate_entrance():
	"""Smooth entrance animation for the license panel"""
	main_panel.modulate.a = 0.0
	main_panel.scale = Vector2(0.8, 0.8)
	
	var entrance_tween = create_tween()
	entrance_tween.set_parallel(true)
	entrance_tween.tween_property(main_panel, "modulate:a", 1.0, 0.5)
	entrance_tween.tween_property(main_panel, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func update_ui_state(is_processing: bool):
	"""Update UI elements based on processing state"""
	validate_button.disabled = is_processing
	license_input.editable = not is_processing
	loading_spinner.visible = is_processing
	
	if is_processing:
		start_loading_animation()
		status_message.text = PROCESSING_MESSAGE
		status_message.modulate = Color(0.4, 0.7, 1.0, 1.0)  # Blue processing color
	else:
		stop_loading_animation()

func start_loading_animation():
	"""Animate the loading spinner"""
	if spinner_tween:
		spinner_tween.kill()
	
	spinner_tween = create_tween()
	spinner_tween.set_loops()
	spinner_tween.tween_property(loading_spinner, "rotation", TAU, 1.0)

func stop_loading_animation():
	"""Stop the loading animation"""
	if spinner_tween:
		spinner_tween.kill()
	loading_spinner.rotation = 0.0

func shake_panel():
	"""Shake animation for invalid input"""
	if shake_tween:
		shake_tween.kill()
	
	var original_position = main_panel.position
	shake_tween = create_tween()
	shake_tween.tween_method(_shake_panel_callback, 0.0, 1.0, 0.5)
	shake_tween.tween_callback(func(): main_panel.position = original_position)

func _shake_panel_callback(progress: float):
	"""Callback for shake animation"""
	var intensity = 20.0 * (1.0 - progress)
	var shake_offset = Vector2(
		sin(progress * PI * 12) * intensity,
		cos(progress * PI * 16) * intensity * 0.5
	)
	main_panel.position = main_panel.position + shake_offset

func show_status_message(message: String, color: Color):
	"""Display status message with color and fade effect"""
	status_message.text = message
	status_message.modulate = color
	
	# Fade animation
	if fade_tween:
		fade_tween.kill()
	
	fade_tween = create_tween()
	fade_tween.tween_property(status_message, "modulate:a", 0.0, 0.1)
	fade_tween.tween_property(status_message, "modulate:a", 1.0, 0.3)

func _on_validate_button_pressed():
	"""Handle validate button press"""
	var license_key = license_input.text.strip_edges()
	if license_key.is_empty():
		show_status_message("⚠️ Please enter a license key", Color(1.0, 0.6, 0.4, 1.0))
		shake_panel()
		return
	
	_validate_license(license_key)

func _on_license_input_text_submitted(new_text: String):
	"""Handle Enter key press in license input"""
	_on_validate_button_pressed()

func _on_help_button_pressed():
	"""Handle help button press"""
	show_status_message("💡 Contact support@forensiscan.com for license assistance", Color(0.7, 0.8, 0.9, 1.0))

func _validate_license(license_key: String):
	"""Validate the provided license key"""
	update_ui_state(true)
	
	# Add a small delay for better UX (simulating network validation)
	await get_tree().create_timer(1.5).timeout
	
	var result = verify_token(license_key)
	if result.ok:
		save_activated_token(license_key, result.payload)
		_on_successful_validation()
	else:
		_on_failed_validation()

func _on_successful_validation():
	"""Handle successful license validation"""
	update_ui_state(false)
	show_status_message(VALID_LICENSE_MESSAGE, Color(0.4, 1.0, 0.6, 1.0))
	
	# Success animation
	var success_tween = create_tween()
	success_tween.set_parallel(true)
	success_tween.tween_property(main_panel, "modulate", Color(0.8, 1.2, 0.8, 1.0), 0.3)
	success_tween.tween_property(main_panel, "scale", Vector2(1.05, 1.05), 0.3)
	
	success_tween.tween_interval(0.3)
	success_tween.tween_property(main_panel, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)
	success_tween.tween_property(main_panel, "scale", Vector2(1.0, 1.0), 0.3)
	
	success_tween.tween_interval(0.5)
	success_tween.tween_callback(func(): 
		license_validated.emit()
	)

func _on_failed_validation():
	"""Handle failed license validation"""
	update_ui_state(false)
	show_status_message(INVALID_LICENSE_MESSAGE, Color(1.0, 0.4, 0.4, 1.0))
	shake_panel()
	
	# Clear the input and refocus
	license_input.text = ""
	license_input.grab_focus()
	
	license_failed.emit()

# === CRYPTO FUNCTIONS ===

# --- HMAC / Base64 helpers ---
static func _hmac_sha256(key: String, data: String) -> PackedByteArray:
	var ctx := HMACContext.new()
	ctx.start(HashingContext.HASH_SHA256, key.to_utf8_buffer())
	ctx.update(data.to_utf8_buffer())
	return ctx.finish()

static func _b64url_decode_to_bytes(s: String) -> PackedByteArray:
	# Restore padding
	var t := s.replace("-", "+").replace("_", "/")
	while t.length() % 4 != 0:
		t += "="
	return Marshalls.base64_to_raw(t)

static func _b64url_decode_to_text(s: String) -> String:
	return _b64url_decode_to_bytes(s).get_string_from_utf8()

# --- Token verification ---
static func verify_token(token: String, expected_name: String = "", expected_semester: String = "", expect_device_lock := false) -> Dictionary:
	# Returns: { ok: bool, reason: String, payload: Dictionary }
	var parts := token.split(".")
	if parts.size() != 2:
		return { "ok": false, "reason": "Invalid token format." }

	var payload_json := ""
	var signature_b64 := ""
	payload_json = _b64url_decode_to_text(parts[0])
	signature_b64 = parts[1]

	# Parse JSON
	var parse := JSON.parse_string(payload_json) as Dictionary
	if typeof(parse) != TYPE_DICTIONARY:
		return { "ok": false, "reason": "Invalid payload JSON." }
	var payload: Dictionary = parse

	# Check signature
	var expected_sig := _hmac_sha256(SECRET_KEY, payload_json)
	var given_sig := _b64url_decode_to_bytes(signature_b64)
	if expected_sig != given_sig:
		return { "ok": false, "reason": "Bad signature." }

	# Optional: check name/semester if you want to enforce exact match
	if expected_name != "" and String(payload.get("name","")) != expected_name:
		return { "ok": false, "reason": "Name mismatch." }
	if expected_semester != "" and String(payload.get("semester","")) != expected_semester:
		return { "ok": false, "reason": "Semester mismatch." }

	# Check expiry (YYYY-MM-DD)
	var expiry := String(payload.get("expiry",""))
	if expiry == "":
		return { "ok": false, "reason": "Missing expiry." }
	var today := Time.get_date_dict_from_system()
	var today_str := "%04d-%02d-%02d" % [today.year, today.month, today.day]
	if today_str > expiry:
		return { "ok": false, "reason": "License expired." }

	# Optional device lock
	if expect_device_lock:
		var want_id := String(payload.get("device_id",""))
		if want_id == "":
			return { "ok": false, "reason": "This license requires device lock but device_id is empty." }
		var device_id := OS.get_unique_id() # stable per device (Android/iOS/desktop)
		if device_id != want_id:
			return { "ok": false, "reason": "Device mismatch." }

	return { "ok": true, "reason": "OK", "payload": payload }

# --- Persist locally after first activation ---
static func save_activated_token(token: String, payload: Dictionary) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("license", "token", token)
	cfg.set_value("license", "activated", true)
	cfg.set_value("license", "payload", payload)
	cfg.save(LICENSE_FILE)

static func load_activated_token() -> String:
	if not FileAccess.file_exists(LICENSE_FILE):
		return ""
	var cfg := ConfigFile.new()
	if cfg.load(LICENSE_FILE) != OK:
		return ""
	return String(cfg.get_value("license", "token", ""))

static func is_activated() -> bool:
	if not FileAccess.file_exists(LICENSE_FILE):
		return false
	var cfg := ConfigFile.new()
	if cfg.load(LICENSE_FILE) != OK:
		return false
	# Double check - if activated, validate the stored token is still valid
	var activated = bool(cfg.get_value("license", "activated", false))
	if activated:
		var stored_token = String(cfg.get_value("license", "token", ""))
		if stored_token != "":
			var result = verify_token(stored_token)
			return result.ok
	return false
	
static func get_license_details() -> Dictionary:
	if not FileAccess.file_exists(LICENSE_FILE):
		return {}
	var cfg := ConfigFile.new()
	if cfg.load(LICENSE_FILE) != OK:
		return {}
	return cfg.get_value("license", "payload", {})
