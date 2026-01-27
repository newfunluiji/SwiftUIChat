# Fix Auto-Send Issue - Step by Step Guide

## Problem
When selecting a photo, it automatically sends instead of showing the attachment row where you can add text before sending.

## Root Cause
The `.onChange(of: inputViewModel.showPicker)` handler (lines 107-119) has logic that auto-sends when `showFullscreenPreview = false`.

Since `cameraSelectionParameters` sets `showFullscreenPreview = false` for single selection, this triggers auto-send.

---

## Solution: Remove Auto-Send Logic

### Step 1: Locate the Code
Open file: `SwiftUIChat/Sources/ExyteChat/Views/Attachments/AttachmentsEditor.swift`

Find lines **107-119** which contain:
```swift
.onChange(of: inputViewModel.showPicker) {
    let showFullscreenPreview = cameraSelectionParameters?.showFullscreenPreview ?? true
    let selectionLimit = cameraSelectionParameters?.selectionLimit ?? 1

    // Handle auto-send case (no preview, single selection)
    if !inputViewModel.showPicker && selectionLimit == 1 && !showFullscreenPreview {
        // Picker closed immediately after selection
        assembleSelectedMedia()
        inputViewModel.send()
    }
}
```

### Step 2: Replace with Simple Version
Replace the entire `.onChange(of: inputViewModel.showPicker)` block with:

```swift
.onChange(of: inputViewModel.showPicker) {
    // Picker dismissed - media is already assembled via completion closure
    // Just let it show in attachment row without auto-sending
}
```

### Step 3: Why This Works
- The MediaPicker completion closure (lines 62-67) already calls `assembleSelectedMedia()` with a delay
- This assembles the media into `inputViewModel.attachments.medias`
- The attachment row will display the selected photo
- User can add text and manually tap send button
- No auto-send happens

---

## Alternative: Keep Auto-Send for Specific Case (Optional)

If you want auto-send ONLY when coming from camera (not photo library), you could use:

```swift
.onChange(of: inputViewModel.showPicker) {
    // Only auto-send if explicitly configured to do so
    // This would require a separate flag to distinguish user intent
}
```

But for the simplest fix: **just remove all the logic inside the onChange handler**.

---

## After the Fix

### Expected Behavior:
1. ✅ User opens photo picker
2. ✅ User selects a photo (no fullscreen preview shown)
3. ✅ Picker closes automatically
4. ✅ Photo appears in attachment row below input field
5. ✅ User can type text message (optional)
6. ✅ User taps send button to send photo + text

### What Changed:
- Photo selection no longer auto-sends
- Attachment row is visible with selected photo
- User has control over when to send
