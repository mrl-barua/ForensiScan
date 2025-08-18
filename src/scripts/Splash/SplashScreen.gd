extends Node

func _ready():
	go_main_screen()

func go_main_screen():
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn")
