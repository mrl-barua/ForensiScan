extends Node

@onready var progress_bar = $CanvasLayer/CenterContainer/MainPanel/ContentContainer/LoadingContainer/ProgressContainer/ProgressBar
@onready var loading_label = $CanvasLayer/CenterContainer/MainPanel/ContentContainer/LoadingContainer/LoadingLabel
@onready var percentage_label = $CanvasLayer/CenterContainer/MainPanel/ContentContainer/LoadingContainer/ProgressContainer/PercentageLabel
@onready var main_panel = $CanvasLayer/CenterContainer/MainPanel
@onready var app_icon = $CanvasLayer/CenterContainer/MainPanel/ContentContainer/HeaderContainer/AppIcon

var loading_progress: float = 0.0
var loading_messages = [
	"🔧 Initializing ForensiScan...",
	"📚 Loading Digital Forensics Modules...",
	"🎓 Preparing Learning Environment...",
	"⚙️ Setting up Interactive Components...",
	"✨ Finalizing Setup...",
	"🚀 Almost Ready..."
]

var icon_animations = ["🔍", "🔎", "🔍", "🔎"]
var current_icon_index = 0

func _ready():
	# Start icon animation
	animate_icon()
	# Start loading simulation
	simulate_loading()

func animate_icon():
	var tween = create_tween()
	tween.set_loops()
	tween.tween_callback(update_icon).set_delay(0.8)

func update_icon():
	current_icon_index = (current_icon_index + 1) % icon_animations.size()
	app_icon.text = icon_animations[current_icon_index]
	
	# Add subtle scale animation
	var scale_tween = create_tween()
	scale_tween.tween_property(app_icon, "scale", Vector2(1.1, 1.1), 0.1)
	scale_tween.tween_property(app_icon, "scale", Vector2(1.0, 1.0), 0.1)

func simulate_loading():
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Animate progress bar with easing
	tween.tween_method(update_progress, 0.0, 100.0, 4.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	# Change loading messages with proper timing
	var message_interval = 4.0 / loading_messages.size()
	for i in range(loading_messages.size()):
		tween.tween_callback(update_loading_message.bind(loading_messages[i])).set_delay(i * message_interval)

func update_progress(value: float):
	progress_bar.value = value
	percentage_label.text = str(int(value)) + "%"
	
	# Add color changes based on progress
	var progress_ratio = value / 100.0
	var progress_color = Color.CYAN.lerp(Color.GREEN, progress_ratio)
	
	# Update progress bar color (if using StyleBoxFlat)
	if progress_bar.get_theme_stylebox("fill"):
		var style = progress_bar.get_theme_stylebox("fill") as StyleBoxFlat
		if style:
			style.bg_color = progress_color

func update_loading_message(message: String):
	loading_label.text = message
	
	# Add a subtle fade effect to message changes
	var msg_tween = create_tween()
	msg_tween.tween_property(loading_label, "modulate:a", 0.7, 0.1)
	msg_tween.tween_property(loading_label, "modulate:a", 1.0, 0.1)

func _on_animation_player_animation_finished(anim_name):
	# Wait a bit for the loading to complete
	await get_tree().create_timer(0.8).timeout
	go_main_screen()

func go_main_screen():
	# Create smooth fade out transition
	var transition_tween = create_tween()
	transition_tween.set_parallel(true)
	
	# Fade out the main panel
	transition_tween.tween_property(main_panel, "modulate:a", 0.0, 0.6)
	transition_tween.tween_property(main_panel, "scale", Vector2(0.95, 0.95), 0.6)
	
	# Fade out particles
	var particles = $CanvasLayer/ParticleContainer/BackgroundParticles
	if particles:
		transition_tween.tween_property(particles, "modulate:a", 0.0, 0.4)
	
	await transition_tween.finished
	
	# Change to main menu
	get_tree().change_scene_to_file("res://src/scenes/MainMenu.tscn")

