extends Node2D

@export var quit_button: Button
@onready var license_verifier: Control = $LicenseVerifier
@onready var menu_screen: VBoxContainer = $CanvasLayer/MainButtons
@onready var tween: Tween

func _ready() -> void:
	ApplicationManager.resume()
	setup_ui()
	
	if license_verifier.is_activated():
		license_verifier.get_node("CanvasLayer").hide()
		menu_screen.show()
		animate_menu_entrance()
	else:
		pass
		#license_verifier.get_node("CanvasLayer").show()
		#menu_screen.hide();

	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)

func setup_ui():
	# Connect button signals with hover effects
	for button in menu_screen.get_children():
		if button is Button:
			button.mouse_entered.connect(_on_button_hover.bind(button))
			button.mouse_exited.connect(_on_button_unhover.bind(button))

func animate_menu_entrance():
	# Start buttons off-screen
	menu_screen.modulate.a = 0.0
	menu_screen.position.x += 100
	
	# Animate entrance
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(menu_screen, "modulate:a", 1.0, 0.8)
	tween.tween_property(menu_screen, "position:x", 660.0, 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_button_hover(button: Button):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.2).set_trans(Tween.TRANS_BACK)

func _on_button_unhover(button: Button):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK)
		
func _process(delta):
	if license_verifier.is_activated():
		license_verifier.get_node("CanvasLayer").hide()	
		menu_screen.show()
		
func _on_start_prelim_lesson_pressed():
	smooth_transition("res://src/scenes/Lesson/Prelim/Prelim_1.1.tscn")
	
func _on_start_prelim_exam_button_pressed():
	smooth_transition("res://src/scenes/Quiz/Prelim/Prelim_Quiz_1.1.tscn")
	
func _on_start_midterm_button_pressed():
	smooth_transition("res://src/scenes/Lesson/Midterm/Midterm_1.1.tscn")

func _on_button_4_pressed():
	smooth_transition("res://src/scenes/Quiz/Prelim/Prelim_Quiz_1.1.tscn")
	
func _on_quit_button_pressed() -> void:
	animate_exit()
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()

func smooth_transition(scene_path: String):
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(menu_screen, "modulate:a", 0.0, 0.3)
	tween.tween_property(menu_screen, "position:x", 760.0, 0.3).set_trans(Tween.TRANS_BACK)
	
	await tween.finished
	get_tree().change_scene_to_file(scene_path)

func animate_exit():
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(menu_screen, "modulate:a", 0.0, 0.5)
	tween.tween_property(menu_screen, "scale", Vector2(0.8, 0.8), 0.5).set_trans(Tween.TRANS_BACK)
