extends Node

@onready var splash_panel = $CanvasLayer/CenterContainer/SplashPanel
@onready var particles = $CanvasLayer/ParticleContainer/Particles2D

func _ready():
	# Add subtle pulse effect to the developer logo
	var logo = $CanvasLayer/CenterContainer/SplashPanel/ContentContainer/LogoContainer/DeveloperLogo
	if logo:
		var pulse_tween = create_tween()
		pulse_tween.set_loops()
		pulse_tween.tween_property(logo, "scale", Vector2(1.05, 1.05), 1.0)
		pulse_tween.tween_property(logo, "scale", Vector2(1.0, 1.0), 1.0)

func _on_animation_player_animation_finished(anim_name: StringName):
	# Add fade out transition
	var transition_tween = create_tween()
	transition_tween.set_parallel(true)
	
	# Fade out the splash panel
	transition_tween.tween_property(splash_panel, "modulate:a", 0.0, 0.5)
	transition_tween.tween_property(splash_panel, "scale", Vector2(0.9, 0.9), 0.5)
	
	# Fade out particles
	if particles:
		transition_tween.tween_property(particles, "modulate:a", 0.0, 0.3)
	
	await transition_tween.finished
	_go_splash_screen()

func _go_splash_screen():
	get_tree().change_scene_to_file("res://src/scenes/Splash/SplashScreen.tscn")
	
