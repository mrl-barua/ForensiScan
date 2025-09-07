# NavigationControls Page Number Fix

## Problem

The page number in the NavigationControls component was not working correctly. It would always show "Page 1 of 25" regardless of which lesson scene (Prelim or Midterm) was currently active.

## Root Cause

1. The `_update_page_indicator()` function was called in `_ready()` before the scene was fully loaded
2. The NavigationControls component was initially invisible, so scene context wasn't available
3. The regex pattern for extracting page numbers from scene names wasn't robust enough
4. The system only supported Prelim lessons (25 pages) and didn't handle Midterm lessons (65 pages)

## Solution Implemented

### 1. Improved Timing

- Added `visibility_changed` signal connection to update page numbers when the component becomes visible
- Added `await get_tree().process_frame` to ensure scene is properly loaded before extracting page numbers

### 2. Enhanced Page Number Detection

- Added support for both Prelim and Midterm lesson patterns
- Auto-detection of lesson type based on scene filename
- Automatic setting of total pages: Prelim = 25, Midterm = 65
- Added robust regex patterns for both lesson types
- Added fallback mechanisms for different filename patterns
- Added proper error handling for edge cases

### 3. Manual Page Number Override

- Added `@export var manual_page_number: int = 0` property
- When set to a value > 0, this overrides automatic detection
- Can be set directly in scene files for precise control

### 4. Multiple Detection Methods

The system now supports three ways to set page numbers:

#### Method 1: Manual Scene Property (Recommended)

Set `manual_page_number` directly in the scene file:

```
[node name="NavigationControls" parent="." instance=ExtResource("4_in5ny")]
visible = false
manual_page_number = 2
previous_scene_path = "res://src/scenes/Lesson/Prelim/Prelim_1.1.tscn"
next_scene_path = "res://src/scenes/Lesson/Prelim/Prelim_1.3.tscn"
```

#### Method 2: Programmatic Setting

Call `set_page_number()` from lesson scripts:

```gdscript
navigation_buttons.set_page_number(2, 25)
```

#### Method 3: Automatic Detection

The system automatically tries to extract page numbers from scene filenames using regex patterns:

- **Prelim pattern**: `Prelim_1\.(\d+)` (matches "Prelim_1.15" → extracts "15", total pages = 25)
- **Midterm pattern**: `Midterm_1\.(\d+)` (matches "Midterm_1.45" → extracts "45", total pages = 65)
- **Fallback pattern**: `(\d+)` (matches any number in the filename)

## Files Modified

### NavigationControls.gd

- Added `manual_page_number` export variable
- Enhanced `_update_page_indicator()` with robust detection for both Prelim and Midterm
- Added automatic lesson type detection and total page setting
- Added `_on_visibility_changed()` for proper timing
- Added `set_page_number()` method for programmatic control

### Scene Files Updated

**Prelim Lessons (25 total):**

- Updated 23 scenes with `manual_page_number` property (Prelim_1.1 through Prelim_1.24)
- Prelim_1.25 uses custom buttons instead of NavigationControls (intentional)

**Midterm Lessons (65 total):**

- Updated all 65 scenes with `manual_page_number` property (Midterm_1.1 through Midterm_1.65)

### Lesson Scripts Updated

- Removed manual `set_page_number()` calls since scene properties handle this now

## Testing

1. **Prelim Lessons**: Open any scene (e.g., Prelim_1.15.tscn), run it, and verify shows "Page 15 of 25"
2. **Midterm Lessons**: Open any scene (e.g., Midterm_1.45.tscn), run it, and verify shows "Page 45 of 65"
3. Navigate between lessons and verify page numbers update correctly
4. Test both automatic detection and manual override methods

## Automation Scripts

Created Python scripts to mass-update lesson scenes:

- `update_prelim_pages.py`: Updated 20 Prelim scenes automatically
- `update_midterm_pages.py`: Updated 62 Midterm scenes automatically

## Future Maintenance

To add page numbers to new lesson scenes:

1. Add `manual_page_number = X` property to the NavigationControls instance in the scene file
2. For new lesson types, update the regex patterns in `_update_page_indicator()`
3. No script changes needed for existing lesson types - the system will automatically detect them

## Debug Information

The system now includes comprehensive logging:

- Lesson type detection (Prelim vs Midterm)
- Automatic total page setting
- Scene name detection
- Regex pattern matching results
- Fallback detection attempts
- Final page number assignments

Check the Godot output panel for debug messages when testing.
