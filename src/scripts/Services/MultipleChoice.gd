extends Control

# Exported variables for customization
@export var question_text = "What is the answer?"
@export var option_a = "Option A"
@export var option_b = "Option B"
@export var option_c = "Option C"
@export var option_d = "Option D"

# Signal for when an answer is selected
signal answer_selected(option)

# References to UI elements
@onready var question: RichTextLabel =  $Question
@onready var questionA: Button = $VBoxContainer/OptionA
@onready var questionB: Button = $VBoxContainer/OptionB
@onready var questionC: Button = $VBoxContainer/OptionC
@onready var questionD: Button = $VBoxContainer/OptionD

func _ready():
	# Setup initial display
	update_display()

func update_display():
	question.text = question_text 
	questionA.text = option_a
	questionB.text = option_b
	questionC.text = option_c
	questionD.text = option_d

func _on_option_a_pressed():
	emit_signal("answer_selected", option_a) 


func _on_option_b_pressed():
	emit_signal("answer_selected", option_b)


func _on_option_c_pressed():
	emit_signal("answer_selected", option_c)


func _on_option_d_pressed():
	emit_signal("answer_selected", option_d) 
