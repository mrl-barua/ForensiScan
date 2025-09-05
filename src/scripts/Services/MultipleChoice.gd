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
	print("MultipleChoice: _ready() called")
	print("MultipleChoice: Question node = ", question)
	print("MultipleChoice: OptionA node = ", questionA)
	print("MultipleChoice: OptionB node = ", questionB)
	print("MultipleChoice: OptionC node = ", questionC)
	print("MultipleChoice: OptionD node = ", questionD)
	
	# Ensure all nodes are visible
	if question:
		question.visible = true
		print("MultipleChoice: Question visible = ", question.visible)
	if questionA:
		questionA.visible = true
		print("MultipleChoice: OptionA visible = ", questionA.visible)
		
	# Setup initial display
	update_display()

func update_display():
	print("MultipleChoice: update_display() called")
	print("MultipleChoice: Setting question text to: ", question_text)
	
	if question:
		question.text = question_text
		print("MultipleChoice: Question text set to: ", question.text)
	else:
		print("ERROR: Question node is null!")
		
	if questionA:
		questionA.text = option_a
		print("MultipleChoice: OptionA text set to: ", questionA.text)
	else:
		print("ERROR: OptionA node is null!")
		
	if questionB:
		questionB.text = option_b
		print("MultipleChoice: OptionB text set to: ", questionB.text)
	else:
		print("ERROR: OptionB node is null!")
		
	if questionC:
		questionC.text = option_c
		print("MultipleChoice: OptionC text set to: ", questionC.text)
	else:
		print("ERROR: OptionC node is null!")
		
	if questionD:
		questionD.text = option_d
		print("MultipleChoice: OptionD text set to: ", questionD.text)
	else:
		print("ERROR: OptionD node is null!")

func _on_option_a_pressed():
	print("MultipleChoice: Option A pressed - ", option_a)
	answer_selected.emit(option_a)

func _on_option_b_pressed():
	print("MultipleChoice: Option B pressed - ", option_b)
	answer_selected.emit(option_b)

func _on_option_c_pressed():
	print("MultipleChoice: Option C pressed - ", option_c)
	answer_selected.emit(option_c)

func _on_option_d_pressed():
	print("MultipleChoice: Option D pressed - ", option_d)
	answer_selected.emit(option_d) 
