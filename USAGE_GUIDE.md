# ExyteChat Enhanced Attachments - Usage Guide

This guide explains how to use the new document attachment, upload progress, and system message features.

---

## 📎 Document Attachments

### Creating a Document Attachment

```swift
// From a remote URL with metadata
let attachment = Attachment(
    id: UUID().uuidString,
    url: URL(string: "https://example.com/report.pdf")!,
    fileName: "Medical_Report.pdf",
    fileSize: 125000,  // bytes
    mimeType: "application/pdf"
)

// The type is auto-detected from file extension
// .document for PDF, DOC, DOCX, XLS, XLSX, etc.
// .file for unknown types
```

### Supported Document Types

| Extension | Type | SF Symbol |
|-----------|------|-----------|
| `.pdf` | `.document` | `doc.text.fill` |
| `.doc`, `.docx` | `.document` | `doc.richtext.fill` |
| `.xls`, `.xlsx` | `.document` | `tablecells.fill` |
| `.ppt`, `.pptx` | `.document` | `rectangle.on.rectangle.angled` |
| `.txt` | `.document` | `doc.plaintext.fill` |
| Other | `.file` | `doc.fill` |

### Displaying File Info

```swift
let attachment: Attachment = ...

// Get display name
let name = attachment.displayName  // "Medical_Report.pdf"

// Get formatted file size
let size = attachment.formattedFileSize  // "125 KB"

// Get SF Symbol name for icon
let icon = attachment.iconName  // "doc.text.fill"

// Check if it's a document
if attachment.isDocument {
    // Show document cell instead of image
}
```

---

## 📤 Upload Progress

### Setting Upload Progress on Attachment

```swift
var message = Message(...)

// Update attachment progress (0.0 to 1.0)
message.attachments[0].uploadProgress = 0.5  // 50%

// Progress will show circular indicator overlay
// When nil or >= 1.0, progress indicator is hidden
```

### Setting Upload Progress on Message

```swift
var message = Message(
    id: UUID().uuidString,
    user: currentUser,
    status: .sending,
    uploadProgress: 0.3  // 30% overall progress
)

// Update as upload progresses
message.uploadProgress = 0.7  // 70%

// Clear when done
message.uploadProgress = nil
```

### Progress States

| Value | Display |
|-------|---------|
| `nil` | No progress shown (or indeterminate spinner if `.sending`) |
| `0.0 - 0.99` | Circular progress with percentage |
| `1.0` | Complete, progress hidden |

---

## 💬 System Messages

### Creating a System Message

```swift
// Simple system message
let systemMessage = Message(
    id: UUID().uuidString,
    systemMessage: "Anton Atanasov joined the conversation"
)

// With specific date
let systemMessage = Message(
    id: UUID().uuidString,
    systemMessage: "Consultation ended",
    createdAt: Date()
)
```

### Checking if Message is System Type

```swift
let message: Message = ...

if message.isSystemMessage {
    // Handle system message differently
}

// Or check the type directly
if case .system(let text) = message.messageType {
    print("System message: \(text)")
}
```

### System Message Display

System messages are automatically rendered:
- Centered in the chat
- No avatar or bubble
- Muted gray text
- With horizontal lines on sides
- Optional timestamp below

---

## 📁 File Picker in Input View

### How It Works

The attachment button now shows a menu with three options:
1. **Photo Library** - Opens media picker for photos/videos
2. **Take Photo** - Opens camera
3. **Browse** - Opens document picker for files

### Handling Draft Messages with Files

```swift
// In your ChatView setup
ChatView(messages: messages) { draft in
    // draft.medias - Media from photo picker
    // draft.files - FileAttachment from document picker
    
    // Upload files
    for file in draft.files {
        let url = file.url        // Local file URL
        let name = file.fileName  // "document.pdf"
        let size = file.fileSize  // 125000
        let mime = file.mimeType  // "application/pdf"
        
        // Upload to your server...
    }
}
```

### FileAttachment Structure

```swift
public struct FileAttachment {
    let id: String
    let url: URL           // Local file URL (copied to temp)
    let fileName: String   // Original filename
    let fileSize: Int64?   // Size in bytes
    let mimeType: String?  // MIME type
    
    // Computed properties
    var fileExtension: String
    var iconName: String           // SF Symbol
    var formattedFileSize: String? // "125 KB"
}
```

---

## 🔄 Migration Steps

### 1. Update Message Creation

**Before:**
```swift
let message = Message(
    id: id,
    user: user,
    text: text,
    attachments: attachments
)
```

**After (unchanged, but new options available):**
```swift
// Regular message (unchanged)
let message = Message(
    id: id,
    user: user,
    text: text,
    attachments: attachments
)

// With upload progress
let message = Message(
    id: id,
    user: user,
    text: text,
    attachments: attachments,
    uploadProgress: 0.5
)

// System message
let systemMessage = Message(
    id: id,
    systemMessage: "User joined"
)
```

### 2. Update Attachment Creation

**Before:**
```swift
let attachment = Attachment(
    id: id,
    url: imageURL,
    type: .image
)
```

**After (for documents):**
```swift
// For documents
let attachment = Attachment(
    id: id,
    url: documentURL,
    fileName: "report.pdf",
    fileSize: fileSize,
    mimeType: "application/pdf"
)

// For images (unchanged)
let attachment = Attachment(
    id: id,
    url: imageURL,
    type: .image
)
```

### 3. Handle Files in Draft

**Before:**
```swift
ChatView(messages: messages) { draft in
    let text = draft.text
    let medias = draft.medias
    // ...
}
```

**After:**
```swift
ChatView(messages: messages) { draft in
    let text = draft.text
    let medias = draft.medias
    let files = draft.files  // NEW: Document attachments
    
    // Upload files to your server
    for file in files {
        await uploadFile(file)
    }
}
```

### 4. Document Preview (Automatic)

When user taps on a document attachment:
- QuickLook preview opens automatically
- Remote files are downloaded first
- Supports PDF, Office docs, images, text files

---

## 📱 Example: Complete Message Flow

```swift
// 1. User selects a file from document picker
// (Handled automatically by InputView)

// 2. In your send handler, receive the draft
func handleSendMessage(_ draft: DraftMessage) async {
    // Create message with sending status
    var message = Message(
        id: UUID().uuidString,
        user: currentUser,
        status: .sending,
        text: draft.text,
        uploadProgress: 0.0
    )
    
    // Add to messages immediately
    messages.append(message)
    
    // Upload files
    var uploadedAttachments: [Attachment] = []
    
    for (index, file) in draft.files.enumerated() {
        // Update progress
        message.uploadProgress = Double(index) / Double(draft.files.count)
        
        // Upload file
        let remoteURL = await uploadFile(file)
        
        // Create attachment with remote URL
        let attachment = Attachment(
            id: file.id,
            url: remoteURL,
            fileName: file.fileName,
            fileSize: file.fileSize,
            mimeType: file.mimeType
        )
        uploadedAttachments.append(attachment)
    }
    
    // Update message with attachments
    message.attachments = uploadedAttachments
    message.uploadProgress = nil
    message.status = .sent
    
    // Update in messages array
    if let index = messages.firstIndex(where: { $0.id == message.id }) {
        messages[index] = message
    }
}

// 3. Add system messages as needed
func addSystemMessage(_ text: String) {
    let systemMessage = Message(
        id: UUID().uuidString,
        systemMessage: text
    )
    messages.append(systemMessage)
}

// Example: "Doctor joined the consultation"
addSystemMessage("Dr. Smith joined the consultation")
```

---

## ⚠️ Breaking Changes

None! All changes are additive and backward compatible:

- Existing `Attachment` initializers still work
- Existing `Message` initializers still work  
- `DraftMessage.files` defaults to empty array
- `Message.messageType` defaults to `.regular`
- `Message.uploadProgress` defaults to `nil`

---

## 📱 Input View File & Media Previews

ExyteChat now shows file and image previews in the input area before sending. The "+" button menu provides Camera, Photos, and Files options.

### Integration Instructions

To integrate this in your chat view (e.g., `ConsultationChatView`), make these changes:

#### 1. Remove Redundant State Variables

Delete these state variables as ExyteChat handles them internally:

```swift
// DELETE THESE:
@State private var showingFilePicker = false
@State private var showingImagePicker = false
@State private var selectedPhotoItem: PhotosPickerItem?
```

#### 2. Remove Manual Picker Modifiers

Delete these modifiers from your view body:

```swift
// DELETE THIS:
.photosPicker(
    isPresented: $showingImagePicker, 
    selection: $selectedPhotoItem, 
    matching: .images
)
.onChange(of: selectedPhotoItem) { newItem in
    handleSelectedPhoto(newItem)
}
.fileImporter(
    isPresented: $showingFilePicker,
    allowedContentTypes: [.pdf, .image],
    allowsMultipleSelection: false
) { result in
    handleFileImport(result)
}
```

#### 3. Remove Custom File Attachment UI

Delete the `FileAttachmentBar` usage and component:

```swift
// DELETE THIS from body:
if interactor.isConnected {
    FileAttachmentBar(
        onImageTap: { showingImagePicker = true },
        onFileTap: { showingFilePicker = true }
    )
}

// DELETE the entire FileAttachmentBar struct
```

#### 4. Remove Unused Helper Methods

Delete these methods as they're no longer needed:

```swift
// DELETE THESE METHODS:
private func handleSelectedPhoto(_ item: PhotosPickerItem?) { ... }
private func handleFileImport(_ result: Result<[URL], Error>) { ... }
```

#### 5. Update handleDraftMessage to Process Files

Modify your `handleDraftMessage` method to handle both medias AND files:

```swift
private func handleDraftMessage(_ draft: DraftMessage) {
    // Handle file attachments (PDF, documents, etc.)
    if !draft.files.isEmpty {
        Task {
            for file in draft.files {
                await interactor.uploadAndSendFile(
                    fileURL: file.url,
                    contentType: file.mimeType ?? "application/octet-stream",
                    messageText: ""
                )
            }
        }
        return
    }
    
    // Handle media from photo picker (images)
    if !draft.medias.isEmpty {
        Task {
            for media in draft.medias {
                if let data = await media.getData() {
                    let tempURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent(UUID().uuidString)
                        .appendingPathExtension("jpg")
                    
                    do {
                        try data.write(to: tempURL)
                        await interactor.uploadAndSendFile(
                            fileURL: tempURL,
                            contentType: "image/jpeg",
                            messageText: ""
                        )
                        try? FileManager.default.removeItem(at: tempURL)
                    } catch {
                        print("Failed to process media: \(error)")
                    }
                }
            }
        }
        return
    }
    
    // Handle text-only messages
    viewModel.send(draft: draft)
}
```

#### 6. Remove PhotosUI Import (Optional)

If no longer using PhotosPicker elsewhere:

```swift
// Can remove if not used elsewhere:
import PhotosUI
```

### Result

After these changes:
- The "+" button in the input view shows Camera/Photos/Files menu
- Selected images appear as 60x60pt thumbnails with X remove buttons
- Selected files appear as rows with icon, filename, size, and X remove buttons
- All attachments use your app's theme colors via `chatTheme`
- `handleDraftMessage` receives `DraftMessage` with populated `files` and `medias` arrays
