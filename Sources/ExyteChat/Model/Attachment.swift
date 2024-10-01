//
//  Created by Alex.M on 16.06.2022.
//

import Foundation
import ExyteMediaPicker

public enum AttachmentType: String, Codable {
    case file
    case image
    case video

    public var title: String {
        switch self {
        case .file:
            return "File"
        case .image:
            return "Image"
        default:
            return "Video"
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
        default:
            self = .file // Set a default case if none matches
        }
    }
}

public struct Attachment: Codable, Identifiable, Hashable {
    public let id: String
    public let thumbnail: URL
    public let full: URL
    public let type: AttachmentType

    public init(id: String, thumbnail: URL, full: URL, type: AttachmentType) {
        self.id = id
        self.thumbnail = thumbnail
        self.full = full
        self.type = type
    }

    public init(id: String, url: URL, type: AttachmentType) {
        self.init(id: id, thumbnail: url, full: url, type: type)
    }
}
