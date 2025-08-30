extends Node2D

@export var question_text = "What is the answer?"
@export var option_a = "Option A"
@export var option_b = "Option B"
@export var option_c = "Option C"
@export var option_d = "Option D"

signal answer_selected(option)

@onready var question =  $Label
@onready var questionA = $VBoxContainer/OptionA
@onready var questionB = $VBoxContainer/OptionB
@onready var questionC = $VBoxContainer/OptionC
@onready var questionD = $VBoxContainer/OptionD

func _ready():
	update_display()

func update_display():
	question.text = question_text 
	questionA.text = option_a
	questionB.text = option_b
	questionC.text = option_c
	questionD.text = option_d

func _on_option_a_pressed():
	emit_signal("answer_selected", "A") 

func _on_option_b_pressed():
	emit_signal("answer_selected", "B")

func _on_option_c_pressed():
	emit_signal("answer_selected", "C")

func _on_option_d_pressed():
	emit_signal("answer_selected", "D") 
