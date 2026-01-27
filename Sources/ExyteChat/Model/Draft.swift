//
//  Created by Alex.M on 17.06.2022.
//

import Foundation
import GiphyUISDK
import ExyteMediaPicker

// MARK: - FileAttachment

/// Represents a file attachment that can be uploaded
public struct FileAttachment: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let url: URL
    public let fileName: String
    public var fileSize: Int64?
    public var mimeType: String?
    
    /// Local file data (for upload before URL is available)
    public var data: Data?
    
    public init(id: String = UUID().uuidString,
                url: URL,
                fileName: String,
                fileSize: Int64? = nil,
                mimeType: String? = nil,
                data: Data? = nil) {
        self.id = id
        self.url = url
        self.fileName = fileName
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.data = data
    }
    
    /// Convenience initializer from a local file URL
    public init(fileURL: URL) {
        self.id = UUID().uuidString
        self.url = fileURL
        self.fileName = fileURL.lastPathComponent
        
        // Try to get file size
        if let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
           let size = attributes[.size] as? Int64 {
            self.fileSize = size
        }
        
        // Try to get MIME type
        self.mimeType = FileAttachment.mimeType(for: fileURL.pathExtension)
        self.data = nil
    }
    
    /// Get file extension
    public var fileExtension: String {
        (fileName as NSString).pathExtension
    }
    
    /// SF Symbol name based on file type
    public var iconName: String {
        switch fileExtension.lowercased() {
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
        case "jpg", "jpeg", "png", "gif", "heic", "webp":
            return "photo.fill"
        case "mp4", "mov", "avi":
            return "video.fill"
        default:
            return "doc.fill"
        }
    }
    
    /// Formatted file size string
    public var formattedFileSize: String? {
        guard let size = fileSize else { return nil }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    /// Get MIME type for file extension
    public static func mimeType(for pathExtension: String) -> String {
        switch pathExtension.lowercased() {
        case "pdf":
            return "application/pdf"
        case "doc":
            return "application/msword"
        case "docx":
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "xls":
            return "application/vnd.ms-excel"
        case "xlsx":
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case "ppt":
            return "application/vnd.ms-powerpoint"
        case "pptx":
            return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case "txt":
            return "text/plain"
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "gif":
            return "image/gif"
        case "heic":
            return "image/heic"
        case "mp4":
            return "video/mp4"
        case "mov":
            return "video/quicktime"
        default:
            return "application/octet-stream"
        }
    }
    
    // Codable conformance - exclude data from encoding
    private enum CodingKeys: String, CodingKey {
        case id, url, fileName, fileSize, mimeType
    }
}

// MARK: - DraftMessage

public struct DraftMessage: Sendable {
    public var id: String?
    public let text: String
    public let medias: [Media]
    public var files: [FileAttachment] = []
    public let giphyMedia: GPHMedia?
    public let recording: Recording?
    public let replyMessage: ReplyMessage?
    public let createdAt: Date

    public init(id: String? = nil,
                text: String,
                medias: [Media],
                files: [FileAttachment] = [],
                giphyMedia: GPHMedia?,
                recording: Recording?,
                replyMessage: ReplyMessage?,
                createdAt: Date) {
        self.id = id
        self.text = text
        self.medias = medias
        self.files = files
        self.giphyMedia = giphyMedia
        self.recording = recording
        self.replyMessage = replyMessage
        self.createdAt = createdAt
    }
    
    /// Legacy initializer for backwards compatibility with [URL] files
    public init(id: String? = nil,
                text: String,
                medias: [Media],
                fileURLs: [URL],
                giphyMedia: GPHMedia?,
                recording: Recording?,
                replyMessage: ReplyMessage?,
                createdAt: Date) {
        self.id = id
        self.text = text
        self.medias = medias
        self.files = fileURLs.map { FileAttachment(fileURL: $0) }
        self.giphyMedia = giphyMedia
        self.recording = recording
        self.replyMessage = replyMessage
        self.createdAt = createdAt
    }
}

