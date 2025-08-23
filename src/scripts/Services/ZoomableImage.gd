extends Control

@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0
@export var image_texture: Texture

@onready var image_rect: TextureRect = $ScrollContainer/TextureRect

var zoom: float = 1.0
var dragging: bool = false
var last_mouse_pos: Vector2

# Track touch points for pinch zoom
var touches := {}

func _ready():
	image_rect.texture = image_texture
	image_rect.anchor_left = 0.5
	image_rect.anchor_top = 0.5
	image_rect.anchor_right = 0.5
	image_rect.anchor_bottom = 0.5
	image_rect.position = Vector2.ZERO

func _unhandled_input(event):
	# Mouse zoom
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_apply_zoom(zoom_speed, event.position)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_apply_zoom(-zoom_speed, event.position)
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

	# Touch input
	if event is InputEventScreenTouch:
		if event.pressed:
			touches[event.index] = event.position
		else:
			touches.erase(event.index)

	if event is InputEventScreenDrag:
		if len(touches) == 1:
			# Single finger drag
			image_rect.position += event.relative
			touches[event.index] = event.position
		elif len(touches) == 2:
			# Pinch zoom
			var keys = touches.keys()
			var p1_old = touches[keys[0]]
			var p2_old = touches[keys[1]]
			var p1_new = p1_old
			var p2_new = p2_old
			if keys[0] == event.index:
				p1_new = event.position
			elif keys[1] == event.index:
				p2_new = event.position

			var old_dist = p1_old.distance_to(p2_old)
			var new_dist = p1_new.distance_to(p2_new)
			if old_dist != 0:
				var factor = new_dist / old_dist
				_apply_zoom(factor - 1, (p1_new + p2_new) * 0.5)

			touches[keys[0]] = p1_new
			touches[keys[1]] = p2_new

func _apply_zoom(delta_zoom: float, zoom_center: Variant = null) -> void:
	var old_zoom = zoom
	zoom = clamp(zoom + delta_zoom, min_zoom, max_zoom)
	image_rect.scale = Vector2.ONE * zoom

	if zoom_center != null:
		# Convert global zoom_center to parent local coordinates
		var parent = image_rect.get_parent() as Control
