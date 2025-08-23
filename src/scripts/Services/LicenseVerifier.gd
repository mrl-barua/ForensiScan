# LicenseVerifier.gd
extends Node
class_name LicenseVerifier

# ⚠️ This must match the generator's key. 
const SECRET_KEY := "HCDC_PROJECT"

const LICENSE_FILE := "user://license.cfg"

@onready var line_edit: LineEdit = $CanvasLayer/VBoxContainer/LineEdit
@onready var label: Label = $CanvasLayer/LicenseLabel
@onready var license_verifier: Control = $CanvasLayer/Container

func _ready():
	if LicenseVerifier.is_activated():
		#label.text = "✅ App already activated!"
		license_verifier.hide()
	else:
		label.text = "Enter your license token"

func _on_activate_button_pressed():
	var token := line_edit.text
	var result := LicenseVerifier.verify_token(token)
	if result.ok:
		LicenseVerifier.save_activated_token(token, result.payload)
		label.text = "✅ License activated successfully!"
	else:
		label.text = "❌ " + result.reason

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
	return bool(cfg.get_value("license", "activated", false))
	
static func get_license_details() -> Dictionary:
	if not FileAccess.file_exists(LICENSE_FILE):
		return {}
	var cfg := ConfigFile.new()
	if cfg.load(LICENSE_FILE) != OK:
		return {}
	return cfg.get_value("license", "payload", {})
