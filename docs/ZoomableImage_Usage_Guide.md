# ZoomableImage Component Usage Guide

## Overview
The ZoomableImage component is a reusable Godot component that displays images with click-to-zoom functionality. When clicked, images open in a full-screen view with zoom, pan, and navigation controls.

## Features
- ✅ **Resizable Preview**: Configurable preview image size
- ✅ **Click to Zoom**: Click any image to open full-screen view
- ✅ **Full-Screen Navigation**: Dedicated full-screen mode with controls
- ✅ **Zoom Controls**: Zoom in, zoom out, and reset zoom
- ✅ **Pan Support**: Mouse drag and touch pan in full-screen mode
- ✅ **Mobile Support**: Touch gestures (pinch to zoom, pan)
- ✅ **Return Navigation**: Return to previous page maintaining state
- ✅ **Customizable Labels**: Custom text below images
- ✅ **Signal System**: Events for integration with other systems

## Quick Start

### 1. Basic Usage in Scene
```gdscript
# Add ZoomableImage.tscn to your scene
# Set properties in the inspector:
# - image_texture: Your image texture
# - image_size: Preview size (Vector2)
# - label_text: Text below image
```

### 2. Programmatic Usage
```gdscript
# Load and instantiate the component
var zoomable_scene = preload("res://src/scenes/Components/ZoomableImage.tscn")
var zoomable_image = zoomable_scene.instantiate()

# Configure the image
var texture = load("res://path/to/your/image.jpg") as Texture2D
zoomable_image.set_image_texture(texture, Vector2(300, 200))
zoomable_image.set_label_text("Click to examine fingerprint")

# Set navigation callback
zoomable_image.set_return_callback(_on_return_from_fullscreen)

# Add to scene
add_child(zoomable_image)
```

## Configuration Properties

### Exported Properties (Set in Inspector)
- `image_texture: Texture2D` - The image to display
- `image_size: Vector2` - Size of the preview image (default: 400x300)
- `zoom_speed: float` - Speed of zoom operations (default: 0.2)
- `min_zoom: float` - Minimum zoom level (default: 0.5)
- `max_zoom: float` - Maximum zoom level (default: 5.0)
- `label_text: String` - Text displayed below the image

## Methods

### Image Management
```gdscript
# Set image texture and optional size
set_image_texture(texture: Texture2D, new_size: Vector2 = Vector2.ZERO)

# Load image from file path
load_image_from_path(path: String) -> bool

# Set preview image size
set_preview_size(new_size: Vector2)

# Set label text
set_label_text(text: String)
```

### Navigation
```gdscript
# Set callback for returning from fullscreen
set_return_callback(callback: Callable)

# Programmatically open/close fullscreen
open_fullscreen()
close_fullscreen()
```

### Zoom Controls
```gdscript
# Zoom operations
zoom_in()
zoom_out()
set_zoom(zoom_level: float)
reset_zoom()
```

## Signals

### Available Signals
```gdscript
# Emitted when image preview is clicked
signal image_clicked

# Emitted when fullscreen view is opened
signal fullscreen_opened

# Emitted when fullscreen view is closed
signal fullscreen_closed
```

### Signal Usage Example
```gdscript
func _ready():
    zoomable_image.image_clicked.connect(_on_image_clicked)
    zoomable_image.fullscreen_opened.connect(_on_fullscreen_opened)
    zoomable_image.fullscreen_closed.connect(_on_fullscreen_closed)

func _on_image_clicked():
    print("User clicked on forensic evidence image")
    # Hide other UI elements, pause timers, etc.

func _on_fullscreen_opened():
    # Hide navigation buttons, pause game logic
    navigation_panel.visible = false

func _on_fullscreen_closed():
    # Restore UI, resume game state
    navigation_panel.visible = true
```

## Controls

### Mouse Controls (Desktop)
- **Click Image**: Open full-screen view
- **Mouse Wheel**: Zoom in/out in full-screen mode
- **Click & Drag**: Pan image in full-screen mode
- **ESC Key**: Close full-screen view

### Touch Controls (Mobile)
- **Tap Image**: Open full-screen view
- **Pinch Gesture**: Zoom in/out in full-screen mode
- **Single Touch Drag**: Pan image in full-screen mode
- **Close Button**: Exit full-screen view

### Button Controls
- **Zoom In (+)**: Increase zoom level
- **Zoom Out (-)**: Decrease zoom level
- **Reset**: Fit image to screen
- **Close (✕)**: Exit full-screen view

## Integration Examples

### Forensic Evidence Gallery
```gdscript
extends Control

@onready var evidence_grid: GridContainer = $EvidenceGrid

func _ready():
    load_evidence_images()

func load_evidence_images():
    var evidence_files = [
        "res://assets/images/Evidence/fingerprint_1.jpg",
        "res://assets/images/Evidence/footprint_1.jpg", 
        "res://assets/images/Evidence/document_1.jpg"
    ]
    
    for i in range(evidence_files.size()):
        var zoomable = create_zoomable_image(evidence_files[i])
        zoomable.set_label_text("Evidence " + str(i + 1))
        zoomable.set_return_callback(_on_return_to_gallery)
        evidence_grid.add_child(zoomable)

func create_zoomable_image(image_path: String) -> Control:
    var zoomable_scene = preload("res://src/scenes/Components/ZoomableImage.tscn")
    var zoomable = zoomable_scene.instantiate()
    zoomable.load_image_from_path(image_path)
    return zoomable

func _on_return_to_gallery():
    # User returned from examining evidence
    # Resume investigation, update progress, etc.
    print("Continuing evidence examination...")
```

### Lesson Integration
```gdscript
extends Control

func setup_lesson_images():
    # Fingerprint analysis lesson
    var fingerprint_image = $LessonContent/FingerprintImage
    fingerprint_image.set_image_texture(fingerprint_texture)
    fingerprint_image.set_label_text("Examine the ridge patterns")
    fingerprint_image.set_return_callback(_on_continue_lesson)
    
    # When user returns, continue with lesson
    fingerprint_image.image_clicked.connect(_on_fingerprint_examined)

func _on_fingerprint_examined():
    # Track that student examined the fingerprint
    progress_manager.mark_activity_completed("fingerprint_examination")

func _on_continue_lesson():
    # Student finished examining image, continue lesson
    show_next_lesson_step()
```

## File Structure
```
src/
├── scenes/Components/
│   ├── ZoomableImage.tscn          # Main component scene
│   └── ZoomableImageDemo.tscn      # Demo/example scene
└── scripts/
    ├── Services/
    │   └── ZoomableImage.gd        # Component script
    └── Lesson/
        └── ZoomableImageDemo.gd    # Demo script
```

## Best Practices

### Performance
- Use compressed textures for large images
- Consider image resolution vs. device capabilities
- Preload frequently used images

### User Experience
- Provide clear labels indicating images are clickable
- Use consistent image sizes within the same context
- Ensure zoom controls are easily accessible on mobile

### Educational Context
- Use meaningful labels that relate to learning objectives
- Integrate with progress tracking systems
- Provide context for why users should examine images

### Accessibility
- Ensure touch targets are at least 44px for mobile
- Use high contrast for control buttons
- Provide alternative text descriptions when possible

## Troubleshooting

### Common Issues
1. **Image not showing**: Check texture path and format (PNG/JPG supported)
2. **Zoom not working**: Ensure min_zoom < max_zoom and zoom_speed > 0
3. **Touch controls not responding**: Check if mouse_filter is set correctly
4. **Return callback not working**: Verify callback is set and callable is valid

### Debug Tips
```gdscript
# Enable debug output
func _ready():
    zoomable_image.image_clicked.connect(_debug_image_clicked)
    
func _debug_image_clicked():
    print("Image clicked - texture: ", zoomable_image.image_texture)
    print("Current zoom: ", zoomable_image.current_zoom)
```

This component is perfect for educational applications, forensic training, medical imaging, art galleries, and any scenario where users need to examine images in detail while maintaining their place in the application flow.
