//
//  Created by Alex.M on 16.06.2022.
//

import Foundation
import ExyteMediaPicker

public enum AttachmentType: String, Codable, Sendable {
    case file
    case image
    case video
    case document  // PDF, DOCX, etc.

    public var title: String {
        switch self {
        case .file:
            return "File"
        case .image:
            return "Image"
        case .video:
            return "Video"
        case .document:
            return "Document"
        }
    }

    public init(mediaType: MediaType) {
        switch mediaType {
        case .image:
            self = .image
        default:
            self = .video
        }
    }

    public init(type: String) {
        switch type.lowercased() {
        case "file":
            self = .file
        case "image":
            self = .image
        case "video":
            self = .video
        case "document":
            self = .document
        default:
            self = .file // Set a default case if none matches
        }
    }
    
    /// Initialize attachment type from file extension
    public init(fileExtension: String?) {
        guard let ext = fileExtension?.lowercased() else {
            self = .file
            return
        }
        switch ext {
        case "jpg", "jpeg", "png", "gif", "heic", "heif", "webp", "bmp", "tiff":
            self = .image
        case "mp4", "mov", "avi", "mkv", "webm", "m4v":
            self = .video
        case "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "txt", "rtf", "csv", "pages", "numbers", "keynote":
            self = .document
        default:
            self = .file
        }
    }
    
    /// Initialize attachment type from MIME type
    public init(mimeType: String?) {
        guard let mime = mimeType?.lowercased() else {
            self = .file
            return
        }
        if mime.hasPrefix("image/") {
            self = .image
        } else if mime.hasPrefix("video/") {
            self = .video
        } else if mime.hasPrefix("application/pdf") ||
                  mime.contains("document") ||
                  mime.contains("spreadsheet") ||
                  mime.contains("presentation") ||
                  mime.hasPrefix("text/") {
            self = .document
        } else {
            self = .file
        }
    }
}

public struct Attachment: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let thumbnail: URL?
    public let full: URL
    public let type: AttachmentType
    
    // File metadata
    public var fileName: String?
    public var fileExtension: String?
    public var fileSize: Int64?
    public var mimeType: String?
    
    // Upload progress (0.0 - 1.0, nil means not uploading or unknown)
    public var uploadProgress: Double?

    public init(id: String, thumbnail: URL?, full: URL, type: AttachmentType,
                fileName: String? = nil, fileExtension: String? = nil,
                fileSize: Int64? = nil, mimeType: String? = nil,
                uploadProgress: Double? = nil) {
        self.id = id
        self.thumbnail = thumbnail
        self.full = full
        self.type = type
        self.fileName = fileName
        self.fileExtension = fileExtension ?? full.pathExtension
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.uploadProgress = uploadProgress
    }
    
    // Legacy initializer for backwards compatibility (thumbnail required)
    public init(id: String, thumbnail: URL, full: URL, type: AttachmentType) {
        self.id = id
        self.thumbnail = thumbnail
        self.full = full
        self.type = type
        self.fileName = nil
        self.fileExtension = full.pathExtension
        self.fileSize = nil
        self.mimeType = nil
        self.uploadProgress = nil
    }

    public init(id: String, url: URL, type: AttachmentType) {
        self.init(id: id, thumbnail: url, full: url, type: type)
    }
    
    /// Convenience initializer for document attachments
    public init(id: String, url: URL, fileName: String, fileSize: Int64? = nil, mimeType: String? = nil) {
        let ext = (fileName as NSString).pathExtension
        self.id = id
        self.thumbnail = nil
        self.full = url
        self.type = AttachmentType(fileExtension: ext)
        self.fileName = fileName
        self.fileExtension = ext
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.uploadProgress = nil
    }
    
    // MARK: - Computed Properties
    
    /// SF Symbol name based on file type
    public var iconName: String {
        switch type {
        case .image:
            return "photo.fill"
        case .video:
            return "video.fill"
        case .document:
            switch fileExtension?.lowercased() {
            case "pdf":
                return "doc.text.fill"
            case "doc", "docx":
                return "doc.richtext.fill"
            case "xls", "xlsx":
                return "tablecells.fill"
            case "ppt", "pptx":
                return "rectangle.on.rectangle.angled"
            case "txt":
                return "doc.plaintext.fill"
            case "csv":
                return "tablecells"
            default:
                return "doc.fill"
            }
        case .file:
            return "paperclip"
        }
    }
    
    /// Formatted file size string (e.g., "125 KB", "2.3 MB")
    public var formattedFileSize: String? {
        guard let size = fileSize else { return nil }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    /// Display name for the attachment
    public var displayName: String {
        if let name = fileName, !name.isEmpty {
            return name
        }
        return full.lastPathComponent
    }
    
    /// Whether this attachment is a document type (non-media)
    public var isDocument: Bool {
        type == .document || type == .file
    }
    
    /// Whether this attachment is currently uploading
    public var isUploading: Bool {
        if let progress = uploadProgress {
            return progress < 1.0
        }
        return false
    }
}
