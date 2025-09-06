# ZoomableImage Component - Centered Resizable Modal

## Overview
The ZoomableImage component now supports a centered, resizable modal window instead of a full-screen overlay. This provides a desktop-style experience while maintaining all Android optimization features.

## Features

### 🪟 Centered Modal Window
- Modal appears at screen center by default
- Maintains aspect ratio and proper sizing
- Smooth fade-in/out animations

### 🔄 Resize Functionality
- Resize handle in bottom-right corner
- Visual resize indicator (⟲ symbol)
- Constrained to min/max size limits
- Prevents window from going off-screen

### 🖱️ Drag Functionality
- Click and drag title bar to move window
- Boundary constraints keep window on screen
- Smooth dragging with position clamping

### 📱 Android Optimizations (Maintained)
- Haptic feedback for touch interactions
- Touch gesture support (pinch, pan, double-tap)
- Mobile-friendly button sizes
- Optimized for touch screens

## Usage

### Basic Setup
```gdscript
# Add to your scene
var zoomable_image = preload("res://src/scenes/Components/ZoomableImage.tscn").instantiate()
add_child(zoomable_image)

# Set image texture
zoomable_image.set_image_texture(your_texture)

# Optional: Set custom preview size
zoomable_image.set_preview_size(Vector2(200, 150))
```

### Modal Configuration
```gdscript
# Set modal window size (optional)
zoomable_image.modal_window_size = Vector2(800, 600)

# Set size constraints (optional)
zoomable_image.modal_min_size = Vector2(400, 300)
zoomable_image.modal_max_size = Vector2(1200, 900)
```

## Implementation Details

### Modal Window Structure
```
ModalOverlay (ColorRect - semi-transparent background)
└── ModalWindow (Panel - the draggable/resizable window)
    ├── TitleBar (Panel - drag area)
    │   ├── TitleBarDragArea (Control - handles dragging)
    │   └── CloseButton (Button - close modal)
    ├── ContentArea (Control - main content)
    │   └── ScrollContainer (ScrollContainer - scrollable content)
    │       └── ModalImageContainer (Control - image container)
    │           └── ModalImage (TextureRect - the actual image)
    ├── BottomControls (HBoxContainer - zoom controls)
    │   ├── ZoomOutButton
    │   ├── ResetZoomButton
    │   └── ZoomInButton
    └── ResizeHandle (Control - resize functionality)
        └── ResizeIndicator (Label - visual resize hint)
```

### Key Variables
- `modal_window_size`: Current modal window size
- `modal_min_size`: Minimum allowed window size
- `modal_max_size`: Maximum allowed window size
- `is_dragging_window`: Flag for drag state
- `is_resizing_window`: Flag for resize state

### Input Handling
- **Title Bar Drag**: Left mouse button on title bar area
- **Window Resize**: Left mouse button on resize handle
- **Touch Support**: All interactions work with touch input
- **Boundary Checking**: Prevents window from moving/resizing off-screen

## Android Compatibility
All previous Android optimizations are maintained:
- AndroidVibrationUtil for haptic feedback
- Touch gesture recognition
- Mobile-friendly UI elements
- Performance optimizations

## Demo Scene
Use `ZoomableImageModal.tscn` to test the functionality:
1. Click on the preview image to open modal
2. Drag the title bar to move the window
3. Drag the resize handle to resize the window
4. Use zoom controls or touch gestures to zoom
5. Click the × button or outside to close

## Example Use Cases
- Document viewers with resizable windows
- Image galleries with detailed view
- Educational content with zoomable diagrams
- Photo editing applications
- CAD/technical drawing viewers
