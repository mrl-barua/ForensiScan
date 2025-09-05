extends Control

signal playback_finished
signal time_changed(current_time: float)

@export_file("*.ogv") var video_path: String
@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var progress_bar: ProgressBar = $ProgressContainer/ProgressBar
@onready var time_label: Label = $ProgressContainer/TimeLabel
@onready var play_pause_button: Button = $ControlsContainer/PlayPauseButton

const SKIP_TIME: float = 10.0

var duration: float = 0.0
var is_playing: bool = false
var was_playing_before_pause: bool = false

func _ready() -> void:
	# Add to video_players group for pause system integration
	add_to_group("video_players")
	
	if video_stream_player:
		video_stream_player.finished.connect(_on_video_finished)
		# Avoid scaling overhead – match the video resolution
		video_stream_player.expand = false  
		if video_path != "":
			load_video(video_path)
	
	# Update progress bar and time every frame
	set_process(true)

func _process(_delta: float) -> void:
	if video_stream_player and video_stream_player.stream:
		var current_time = video_stream_player.stream_position
		var total_time = video_stream_player.stream.get_length()
		
		if total_time > 0:
			progress_bar.value = (current_time / total_time) * 100
			time_label.text = "%s / %s" % [_format_time(current_time), _format_time(total_time)]
		
		if is_playing:
			emit_signal("time_changed", current_time)

func _format_time(seconds: float) -> String:
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [mins, secs]

# Load video stream safely
func load_video(path: String) -> void:
	var video = ResourceLoader.load(path)
	if video is VideoStreamTheora:
		set_video(video)
	else:
		push_error("Invalid or unsupported video file: %s" % path)

# Playback controls
func play() -> void:
	if video_stream_player.stream:
		video_stream_player.play()
		is_playing = true
		play_pause_button.text = "⏸"

func pause() -> void:
	if is_playing:
		was_playing_before_pause = true
		video_stream_player.paused = true
		is_playing = false
		play_pause_button.text = "▶"
	else:
		was_playing_before_pause = false

func resume() -> void:
	if was_playing_before_pause:
		video_stream_player.paused = false
		is_playing = true
		play_pause_button.text = "⏸"
		was_playing_before_pause = false

func stop() -> void:
	video_stream_player.stop()
	is_playing = false
	was_playing_before_pause = false
	play_pause_button.text = "▶"

func _on_play_pause_button_pressed() -> void:
	if is_playing:
		pause()
	else:
		if video_stream_player.paused:
			resume()
		else:
			play()

# Skip & Seek
func skip_forward() -> void:
	if video_stream_player and video_stream_player.stream:
		seek(video_stream_player.stream_position + SKIP_TIME)

func skip_backward() -> void:
	seek(video_stream_player.stream_position - SKIP_TIME)

func seek(time: float) -> void:
	if duration > 0.0:
		var target_time = clamp(time, 0, duration)
		video_stream_player.seek(target_time)

# Stream setup
func set_video(video_stream: VideoStream) -> void:
	video_stream_player.stream = video_stream
	duration = video_stream.get_length()

# Getters
func get_current_time() -> float:
	return video_stream_player.stream_position

func get_duration() -> float:
	return duration

func get_is_playing() -> bool:
	return is_playing

# Signals
func _on_video_finished() -> void:
	is_playing = false
	play_pause_button.text = "▶"
	emit_signal("playback_finished")

func _on_skip_back_button_pressed() -> void:
	skip_backward()

func _on_skip_forward_button_pressed() -> void:
	skip_forward()
