# ZoomableImage Android Optimization Guide

## 📱 **Android Modal Sizing Enhanced!**

Your ZoomableImage component now includes comprehensive Android optimizations for better mobile experience.

## 🎯 **What's New:**

### **1. Larger Default Modal Size** ✅

- **Default size increased** from `800x600` to `900x700`
- **Better visibility** on mobile screens
- **Maintains desktop compatibility**

### **2. Android-Specific Sizing** ✅

- **Automatic detection** of Android devices
- **Nearly fullscreen modal** for mobile devices
- **Customizable padding** from screen edges

### **3. Flexible Sizing Options** ✅

- **Multiple scale modes**: Small (70%), Medium (85%), Large (95%)
- **Fullscreen mode**: Uses entire screen minus padding
- **Easy configuration** through export variables

## ⚙️ **Configuration Options:**

### **In Godot Editor:**

```
Android Settings:
├── Android Use Fullscreen Modal: ✅ (recommended)
├── Android Modal Padding: 40 pixels
└── Android Modal Scale: Large (95%)
```

### **In Code:**

```gdscript
# Configure for maximum mobile experience
zoomable_image.configure_for_android(true, 20)  # Large modal, 20px padding

# Or use scale-based sizing
zoomable_image.android_use_fullscreen_modal = false
zoomable_image.android_modal_scale = 2  # Large scale (95%)
```

## 🔄 **Sizing Modes:**

### **Mode 1: Fullscreen with Padding** (Default)

- **Android**: Screen size minus padding (e.g., 1080x2340 → 1040x2300)
- **Desktop**: Standard size constraints apply

### **Mode 2: Scale-based Sizing**

- **Small (70%)**: Good for quick previews
- **Medium (85%)**: Balanced view
- **Large (95%)**: Maximum content visibility

## 📏 **Size Comparison:**

| Device Type             | Old Size  | New Android Size | Improvement              |
| ----------------------- | --------- | ---------------- | ------------------------ |
| **Phone** (360x640)     | 800x600\* | 320x600          | ✅ Fits screen perfectly |
| **Tablet** (768x1024)   | 800x600   | 728x984          | ✅ 90% more screen usage |
| **Desktop** (1920x1080) | 800x600   | 900x700          | ✅ 17% larger modal      |

\*Old size was clamped to screen, often too small on mobile

## 🎮 **Usage Examples:**

### **Default (Recommended for Android):**

```gdscript
# Component automatically detects Android and uses optimized sizing
var zoomable = preload("res://src/scenes/Components/ZoomableImage.tscn").instantiate()
# No additional setup needed - works great on Android!
```

### **Custom Android Configuration:**

```gdscript
# For apps that need specific sizing
zoomable_image.android_use_fullscreen_modal = true
zoomable_image.android_modal_padding = 30  # More padding
zoomable_image.android_modal_scale = 1     # Medium scale as fallback
```

### **Orientation Change Handling:**

```gdscript
# Call this when device orientation changes
func _on_orientation_changed():
    zoomable_image.adjust_for_orientation()
```

## 🔍 **Debug Output:**

When testing, you'll see console output like:

```
📱 Android detected - using mobile-optimized size: (1040, 2300)
🎯 Modal window centered at: (20, 20) with size: (1040, 2300)
```

## 💡 **Best Practices:**

### ✅ **DO:**

- Use default settings for most Android apps
- Test on different screen sizes
- Consider orientation changes
- Use `configure_for_android()` for fine-tuning

### ❌ **DON'T:**

- Set padding too small (< 20px) - hard to close
- Use small scale on phones - content becomes unreadable
- Forget to test on both portrait and landscape

## 🚀 **Result:**

Your ZoomableImage component now provides an **excellent mobile experience** with:

- ✅ **Larger, more readable content** on Android devices
- ✅ **Automatic platform detection** and optimization
- ✅ **Flexible configuration** for different use cases
- ✅ **Maintains desktop compatibility**

Perfect for forensic analysis, document viewing, and educational content on mobile devices! 📱🔍
