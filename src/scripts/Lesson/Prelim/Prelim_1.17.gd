extends Node2D

@onready var next_button: Button = $NextButton

# Called when the node enters the scene tree for the first time.
func _ready():
	next_button.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_next_button_pressed():
	get_tree().change_scene_to_file("res://src/scenes/Lesson/Prelim/Prelim_1.18.tscn")
