extends Node

@onready var progress_bar = $LoadingContainer/ProgressBar
@onready var loading_label = $LoadingContainer/LoadingLabel

var loading_progress: float = 0.0
var loading_messages = [
	"Initializing ForensiScan...",
	"Loading Digital Forensics Modules...",
	"Preparing Learning Environment...",
	"Setting up Interactive Components...",
	"Almost Ready..."
]

func _ready():
	simulate_loading()

func simulate_loading():
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Animate progress bar
	tween.tween_method(update_progress, 0.0, 100.0, 3.0)
	
	# Change loading messages
	for i in range(loading_messages.size()):
		tween.tween_callback(update_loading_message.bind(loading_messages[i])).set_delay(i * 0.6)

func update_progress(value: float):
	progress_bar.value = value
	
func update_loading_message(message: String):
	loading_label.text = message

func _on_animation_player_animation_finished(anim_name):
	await get_tree().create_timer(0.5).timeout
	go_main_screen()

func go_main_screen():
	# Fade out loading elements
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($LoadingContainer, "modulate:a", 0.0, 0.5)
	if has_node("VersionLabel"):
		tween.tween_property($VersionLabel, "modulate:a", 0.0, 0.5)
	
	await tween.finished
	get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn")

