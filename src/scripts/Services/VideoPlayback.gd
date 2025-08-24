extends Control

signal playback_finished
signal time_changed(current_time: float)

@export var video_path: String
@onready var video_stream_player: VideoStreamPlayer = $ScrollContainer/VideoStreamPlayer

const SKIP_TIME: float = 10.0

var duration: float = 0.0
var is_playing: bool = false

func _ready():
	await ready
	if video_stream_player != null:
		video_stream_player.finished.connect(_on_video_finished)
		if video_path:
			load_video(video_path)

# New method to load video from path
func load_video(path: String):
	var video = load(path)
	if video is VideoStream:
		set_video(video)
	else:
		push_error("Invalid video file path")

# Existing methods remain the same
func play():
	video_stream_player.play()
	is_playing = true

func pause():
	video_stream_player.paused = true
	is_playing = false

func resume():
	video_stream_player.paused = false
	is_playing = true

func stop():
	video_stream_player.stop()
	is_playing = false

func skip_forward():
	seek(video_stream_player.get_stream_position() + SKIP_TIME)

func skip_backward():
	seek(video_stream_player.get_stream_position() - SKIP_TIME)

func seek(time: float):
	var target_time = clamp(time, 0, duration)
	video_stream_player.seek(target_time)

func set_video(video_stream: VideoStream):
	video_stream_player.stream = video_stream
	duration = video_stream_player.stream.get_length()

func get_current_time() -> float:
	return video_stream_player.get_stream_position()

func get_duration() -> float:
	return duration

func get_is_playing() -> bool:
	return is_playing

# Private methods
func _on_video_finished():
	is_playing = false
	emit_signal("playback_finished")

func _on_skip_back_button_pressed():
	skip_backward()

func _on_skip_forward_button_pressed():
	skip_forward()
