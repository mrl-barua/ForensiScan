extends Node2D

@onready var question_1: Button = $Question_1
@onready var question_2: Button = $Question_2
@onready var question_3: Button = $Question_3
@onready var question_4: Button = $Question_4
@onready var question_5: Button = $Question_5
@onready var question_6: Button = $Question_6
@onready var question_7: Button = $Question_7
@onready var question_8: Button = $Question_8
@onready var question_9: Button = $Question_9
@onready var question_10: Button = $Question_10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_option_a_pressed():
	get_tree().change_scene_to_file("res://src/scenes/Quiz/Midterm/Midterm_Quiz_1.2.tscn")
