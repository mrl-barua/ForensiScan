extends Control

@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0
@export var image_texture: Texture

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var image_rect: TextureRect = $ScrollContainer/TextureRect

var zoom: float = 1.0
var dragging: bool = false
var last_mouse_pos: Vector2
var touches := {}

func _ready():
	image_rect.texture = image_texture
	image_rect.custom_minimum_size = image_texture.get_size()
	image_rect.size = image_texture.get_size()
	image_rect.pivot_offset = image_texture.get_size() / 2
	image_rect.position = Vector2.ZERO
	image_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	
	# Enable horizontal and vertical scrolling
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_apply_zoom(zoom_speed, event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_apply_zoom(-zoom_speed, event.position)
	elif event is InputEventMagnifyGesture:
		_apply_zoom(zoom_speed * (event.factor - 1.0))

func _apply_zoom(delta_zoom: float, zoom_center: Variant = null) -> void:
	var old_zoom = zoom
	zoom = clamp(zoom + delta_zoom, min_zoom, max_zoom)
	
	# Update the minimum size of the TextureRect based on zoom
	var new_size = image_texture.get_size() * zoom
	image_rect.custom_minimum_size = new_size
	image_rect.size = new_size
	
	if zoom_center != null:
		var viewport_center = scroll_container.size / 2
		var scroll_offset = (zoom_center - viewport_center) * (zoom / old_zoom)
		scroll_container.scroll_horizontal = scroll_offset.x
		scroll_container.scroll_vertical = scroll_offset.y
	
	image_rect.scale = Vector2.ONE
