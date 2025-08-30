extends Node


func _on_animation_player_animation_finished(anim_name):
	go_main_screen();


func go_main_screen():
	get_tree().change_scene_to_file_to_file("res://src/scenes/MainMenu.tscn")

