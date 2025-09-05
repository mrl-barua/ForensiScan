extends Control

signal playback_finished
signal time_changed(current_time: float)

@export_file("*.ogv") var video_path: String
@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer

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

func pause() -> void:
	if is_playing:
		was_playing_before_pause = true
		video_stream_player.paused = true
		is_playing = false
	else:
		was_playing_before_pause = false

func resume() -> void:
	if was_playing_before_pause:
		video_stream_player.paused = false
		is_playing = true
		was_playing_before_pause = false

func stop() -> void:
	video_stream_player.stop()
	is_playing = false
	was_playing_before_pause = false

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

# Getters
func get_current_time() -> float:
	return video_stream_player.stream_position

func get_duration() -> float:
	return duration

func get_is_playing() -> bool:
	return is_playing

# Signals
func _process(_delta: float) -> void:
	if is_playing:
		emit_signal("time_changed", video_stream_player.stream_position)

func _on_video_finished() -> void:
	is_playing = false
	emit_signal("playback_finished")

func _on_skip_back_button_pressed() -> void:
	skip_backward()

func _on_skip_forward_button_pressed() -> void:
	skip_forward()
