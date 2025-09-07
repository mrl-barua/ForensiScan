extends Node2D

@export var header_text: String = "Illustration:"
@export var detail_one_text: String = "- The person taking the prints should grasp the top of the subject's hand and ensure that the finger to be printed is extended. The roll is a single movement with only enough pressure to provide a clear print. The subject being printed should be told to look away from the fingerprint card and to try not to 'help' the roll. This will reduce smudging and produce a clean impression."
@export var detail_two_text: String = ""
@export var detail_three_text: String = ""
@export var detail_four_text: String = ""
@export var detail_five_text: String = ""
@export var detail_six_text: String = ""
@export var detail_seven_text: String = ""

@onready var header_label: RichTextLabel = $VBoxContainer/Header
@onready var detail_one_label: RichTextLabel = $VBoxContainer/DetailOne 
@onready var detail_two_label: RichTextLabel = $VBoxContainer/DetailTwo
@onready var detail_three_label: RichTextLabel = $VBoxContainer/DetailThree
@onready var detail_four_label: RichTextLabel = $VBoxContainer/DetailFour
@onready var detail_five_label: RichTextLabel = $VBoxContainer/DetailFive
@onready var detail_six_label: RichTextLabel = $VBoxContainer/DetailSix
@onready var detail_seven_label: RichTextLabel = $VBoxContainer/DetailSeven
var typewriter: Typewriter

@onready var navigation_buttons: Control = $NavigationControls
@onready var zoomable_image: Control = $ZoomableImage

func _ready():
	# Track progress for this lesson
	ProgressManager.update_lesson_progress("midterm", 3)
	
	# Setup multiple images for the ZoomableImage component
	# setup_multiple_images()  # Commented out - no multiple images
	
	header_label.text = ''
	detail_one_label.text = ''
	detail_two_label.text = ''
	detail_three_label.text = ''
	detail_four_label.text = ''
	detail_five_label.text = ''
	detail_six_label.text = ''
	detail_seven_label.text = ''
	typewriter = Typewriter.new()
	add_child(typewriter)  
	
	typewriter.typing_finished.connect(_on_header_typing_done)
	typewriter.start_typing(header_label, header_text)

func setup_multiple_images():
	if zoomable_image:
		# Set custom VBox separation
		zoomable_image.set_vbox_separation(30)
		
		# Create array of image textures
		var image_textures: Array[Texture2D] = []
		
		# Try to load multiple midterm images
		var image_paths = [
			"res://assets/images/Lesson/Midterm/Midterm_1.3.1.jpg",
			"res://assets/images/Lesson/Midterm/Midterm_1.14.jpg",
			"res://assets/images/Lesson/Midterm/Midterm_1.15.jpg"
		]
		
		for path in image_paths:
			var texture = load(path) as Texture2D
			if texture:
				image_textures.append(texture)
				print("Loaded image: ", path)
			else:
				print("Failed to load image: ", path)
		
		# Set the multiple images
		if image_textures.size() > 0:
			zoomable_image.set_image_textures(image_textures)
			print("Set ", image_textures.size(), " images to ZoomableImage component")
		else:
			print("Warning: No images loaded for ZoomableImage component")

func _on_header_typing_done():
	print("Header typing finished!")
	typewriter.typing_finished.disconnect(_on_header_typing_done)
	typewriter.typing_finished.connect(_on_detail_one_typing_done)
	typewriter.start_typing(detail_one_label, detail_one_text)

func _on_detail_one_typing_done():
	print("Detail one typing finished!")
	typewriter.typing_finished.disconnect(_on_detail_one_typing_done)
	typewriter.typing_finished.connect(_on_detail_two_typing_done)
	typewriter.start_typing(detail_two_label, detail_two_text)


func _on_detail_two_typing_done():
	print("Detail two typing finished!")
	typewriter.typing_finished.disconnect(_on_detail_two_typing_done)
	typewriter.typing_finished.connect(_on_detail_three_typing_done)
	typewriter.start_typing(detail_three_label, detail_three_text)
	
func _on_detail_three_typing_done():
	print("Detail three typing finished!")
	typewriter.typing_finished.disconnect(_on_detail_three_typing_done)
	typewriter.typing_finished.connect(_on_detail_four_typing_done)
	typewriter.start_typing(detail_four_label, detail_four_text)
	
func _on_detail_four_typing_done():
	print("Detail four typing finished!")
	typewriter.typing_finished.disconnect(_on_detail_four_typing_done)
	typewriter.typing_finished.connect(_on_detail_five_typing_done)
	typewriter.start_typing(detail_five_label, detail_five_text)
	
func _on_detail_five_typing_done():
	print("Detail five typing finished!")
	typewriter.typing_finished.disconnect(_on_detail_five_typing_done)
	typewriter.typing_finished.connect(_on_detail_six_typing_done)
	typewriter.start_typing(detail_six_label, detail_six_text)
	
func _on_detail_six_typing_done():
	print("Detail six typing finished!")
	typewriter.typing_finished.disconnect(_on_detail_six_typing_done)
	typewriter.typing_finished.connect(_on_detail_seven_typing_done)
	typewriter.start_typing(detail_seven_label, detail_seven_text)
	
func _on_detail_seven_typing_done():
	print("Detail seven typing finished!")
	navigation_buttons.show()
