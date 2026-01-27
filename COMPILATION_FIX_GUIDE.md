# Fixing Compilation Errors After ExyteChat Updates

## Quick Fix Steps

### Step 1: Clean Build Folder
In Xcode: **Product > Clean Build Folder** (⇧⌘K)

### Step 2: Reset Package Cache
```bash
# In terminal, from your project directory:
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/Library/Developer/Xcode/DerivedData

# Then in Xcode:
# File > Packages > Reset Package Caches
```

### Step 3: Update Package
In Xcode: **File > Packages > Update to Latest Package Versions**

---

## Common Error Fixes

### Error: "Missing argument for parameter 'user' in call"

**Before (Old API):**
```swift
let message = Message(
    id: id,
    text: text,
    attachments: attachments
)
```

**After (New API - Option 1: Keep using old initializer):**
```swift
let message = Message(
    id: id,
    user: user,  // ADD THIS
    text: text,
    attachments: attachments
)
```

**After (New API - Option 2: Use all defaults):**
```swift
let message = Message(
    id: id,
    user: user,
    status: nil,
    createdAt: Date(),
    text: text,
    attachments: attachments,
    recording: nil,
    replyMessage: nil,
    messageType: .regular,  // Default
    uploadProgress: nil      // Default
)
```

### Error: "Extra argument 'systemMessage' in call"

This happens when trying to create a system message incorrectly.

**Correct way to create system message:**
```swift
// Use the convenience initializer
let systemMessage = Message(
    id: UUID().uuidString,
    systemMessage: "User joined the conversation"
)

// Or manually with messageType
let systemMessage = Message(
    id: UUID().uuidString,
    user: User(id: "system", name: "System", avatarURL: nil, isCurrentUser: false),
    text: "User joined",
    messageType: .system("User joined")
)
```

### Error: "Cannot find 'uploadProgress' in scope"

The property exists but needs to be accessed as a property of `Message` or `Attachment`:

```swift
// Set upload progress on message
var message = Message(...)
message.uploadProgress = 0.5  // 50%

// Set upload progress on attachment
var attachment = Attachment(...)
attachment.uploadProgress = 0.5  // 50%
```

### Error: "Cannot find 'fileName' in scope"

Same as above - access as property:

```swift
let attachment = Attachment(
    id: UUID().uuidString,
    url: fileURL,
    fileName: "document.pdf",  // Pass in initializer
    fileSize: 125000,
    mimeType: "application/pdf"
)

// Or access later
let name = attachment.fileName
```

### Error: "Cannot convert value of type 'AttachmentType' to expected argument type 'ImageResource'"

This happens when AttachmentType is being used where an image is expected.

**Fix:**
```swift
// Use the attachment type correctly
let attachment = Attachment(
    id: UUID().uuidString,
    url: fileURL,
    type: .document  // Or .file, .image, .video
)

// NOT:
let image = AttachmentType.document  // ❌ Wrong
```

---

## Breaking Changes to Watch For

### 1. Attachment.thumbnail is now optional

**Before:**
```swift
let attachment = Attachment(
    id: id,
    thumbnail: thumbnailURL,  // URL (required)
    full: fullURL,
    type: .image
)
```

**After:**
```swift
let attachment = Attachment(
    id: id,
    thumbnail: thumbnailURL,  // URL? (optional)
    full: fullURL,
    type: .image
)

// For documents without thumbnails:
let attachment = Attachment(
    id: id,
    thumbnail: nil,  // OK now
    full: documentURL,
    type: .document
)
```

### 2. New Attachment initializer for documents

**Use this for PDFs, DOCs, etc:**
```swift
let attachment = Attachment(
    id: UUID().uuidString,
    url: documentURL,
    fileName: "report.pdf",
    fileSize: 125000,
    mimeType: "application/pdf"
)
// Type is auto-detected from filename
// thumbnail is automatically nil for documents
```

### 3. DraftMessage now includes files

**Before:**
```swift
let draft = DraftMessage(
    text: text,
    medias: medias,
    recording: recording,
    replyMessage: replyMessage,
    createdAt: Date()
)
```

**After:**
```swift
let draft = DraftMessage(
    text: text,
    medias: medias,
    files: [],  // NEW: Add this
    recording: recording,
    replyMessage: replyMessage,
    createdAt: Date()
)
```

---

## If Errors Persist

1. **Check import statement:**
   ```swift
   import ExyteChat  // Make sure this is present
   ```

2. **Verify package is up to date:**
   - In Xcode, go to File > Packages > Update to Latest Package Versions
   - Or manually update the package reference in Package.swift

3. **Check for multiple definitions:**
   - Make sure you don't have duplicate model files (Message.swift, Attachment.swift) in your project
   - The ones from ExyteChat package should be used

4. **Restart Xcode:**
   - Sometimes Xcode needs a restart to pick up package changes
   - Close Xcode completely and reopen

5. **Check minimum deployment target:**
   - iOS 15.0+ required for some features
   - macOS 11.0+ required

---

## Example: Complete Migration

**Old Code:**
```swift
// Creating a message with attachment
let attachment = Attachment(
    id: UUID().uuidString,
    thumbnail: imageURL,
    full: imageURL,
    type: .image
)

let message = Message(
    id: UUID().uuidString,
    user: currentUser,
    status: .sending,
    text: "Check this out",
    attachments: [attachment]
)
```

**New Code (Backward Compatible):**
```swift
// Same as before - still works!
let attachment = Attachment(
    id: UUID().uuidString,
    thumbnail: imageURL,
    full: imageURL,
    type: .image
)

let message = Message(
    id: UUID().uuidString,
    user: currentUser,
    status: .sending,
    text: "Check this out",
    attachments: [attachment]
)

// But now you can also add:
message.uploadProgress = 0.5  // Show progress
```

**New Code (With Documents):**
```swift
// For PDF/document attachments
let docAttachment = Attachment(
    id: UUID().uuidString,
    url: pdfURL,
    fileName: "report.pdf",
    fileSize: 125000,
    mimeType: "application/pdf"
)

let message = Message(
    id: UUID().uuidString,
    user: currentUser,
    text: "Here's the report",
    attachments: [docAttachment]
)
```

**New Code (System Message):**
```swift
// Create a system message
let systemMessage = Message(
    id: UUID().uuidString,
    systemMessage: "Doctor joined the consultation"
)

messages.append(systemMessage)
```
