extends Node2D

@onready var license_name: Label = $CanvasLayer/Name
@onready var license_semester: Label = $CanvasLayer/Semester
@onready var license_registered_device: Label = $CanvasLayer/RegisteredDevice

func _ready():
	var details = LicenseProcessor.get_license_details()
	
	if details.size() > 0:
		license_name.text = "Name: " + str(details.get("name", "Unknown"))
		license_semester.text = "Semester: " + str(details.get("semester", "N/A"))
		license_registered_device.text = "Device ID: " + str(details.get("device_id", "Not Registered"))
	else:
		license_name.text = "❌ No license found"
		license_semester.text = ""
		license_registered_device.text = ""
