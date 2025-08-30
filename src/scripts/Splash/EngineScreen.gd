extends Node

func _on_animation_player_animation_finished(anim_name: StringName):
	_go_splash_screen();

func _go_splash_screen():
	get_tree().change_scene_to_file_to_file("res://src/scenes/Splash/SplashScreen.tscn")
	
