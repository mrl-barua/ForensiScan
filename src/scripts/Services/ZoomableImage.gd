extends Control

@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0
@export var image_texture: Texture

@onready var image_rect: TextureRect = $ScrollContainer/TextureRect

var zoom: float = 1.0
var dragging: bool = false
var last_mouse_pos: Vector2

func _ready():
	image_rect.texture = image_texture
	# Center the TextureRect
	image_rect.anchor_left = 0.5
	image_rect.anchor_top = 0.5
	image_rect.anchor_right = 0.5
	image_rect.anchor_bottom = 0.5
	image_rect.position = Vector2.ZERO

func _unhandled_input(event):
	# Desktop zoom via mouse wheel
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_apply_zoom(zoom_speed)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_apply_zoom(-zoom_speed)
			elif event.button_index == MOUSE_BUTTON_LEFT:
				dragging = true
				last_mouse_pos = event.position
		else:
			if event.button_index == MOUSE_BUTTON_LEFT:
				dragging = false

	# Dragging
	if event is InputEventMouseMotion and dragging:
		var delta = event.position - last_mouse_pos
		image_rect.position += delta
		last_mouse_pos = event.position

	# Touch pinch zoom (Android)
	if event is InputEventMagnifyGesture:
		_apply_zoom(event.factor - 1)

	# Touch drag (Android)
	if event is InputEventScreenDrag:
		image_rect.position += event.relative

func _apply_zoom(delta_zoom: float):
	zoom = clamp(zoom + delta_zoom, min_zoom, max_zoom)
	image_rect.scale = Vector2.ONE * zoom
