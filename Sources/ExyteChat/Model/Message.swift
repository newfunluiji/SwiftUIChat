//
//  Message.swift
//  Chat
//
//  Created by Alisa Mylnikova on 20.04.2022.
//

import SwiftUI
import QuickLookThumbnailing

public struct Message: Identifiable, Hashable {

    public enum Status: Equatable, Hashable {
        case sending
        case sent
        case read
        case error(DraftMessage)

        public func hash(into hasher: inout Hasher) {
            switch self {
            case .sending:
                return hasher.combine("sending")
            case .sent:
                return hasher.combine("sent")
            case .read:
                return hasher.combine("read")
            case .error:
                return hasher.combine("error")
            }
        }

        public static func == (lhs: Message.Status, rhs: Message.Status) -> Bool {
            switch (lhs, rhs) {
            case (.sending, .sending):
                return true
            case (.sent, .sent):
                return true
            case (.read, .read):
                return true
            case ( .error(_), .error(_)):
                return true
            default:
                return false
            }
        }
    }

    public var id: String
    public var user: User
    public var status: Status?
    public var createdAt: Date

    public var text: String
    public var attachments: [Attachment]
    public var recording: Recording?
    public var replyMessage: ReplyMessage?

    public var triggerRedraw: UUID?

    public init(id: String,
                user: User,
                status: Status? = nil,
                createdAt: Date = Date(),
                text: String = "",
                attachments: [Attachment] = [],
                recording: Recording? = nil,
                replyMessage: ReplyMessage? = nil) {

        self.id = id
        self.user = user
        self.status = status
        self.createdAt = createdAt
        self.text = text
        self.attachments = attachments
        self.recording = recording
        self.replyMessage = replyMessage
    }

    public static func makeMessage(
        id: String,
        user: User,
        status: Status? = nil,
        draft: DraftMessage) async -> Message {
            let attachments = await draft.medias.asyncCompactMap { media -> Attachment? in
                guard let thumbnailURL = await media.getThumbnailURL() else {
                    return nil
                }

                switch media.type {
                case .image:
                    return Attachment(id: UUID().uuidString, url: thumbnailURL, type: .image)
                case .video:
                    guard let fullURL = await media.getURL() else {
                        return nil
                    }
                    return Attachment(id: UUID().uuidString, thumbnail: thumbnailURL, full: fullURL, type: .video)
                }
            }
            let fileAttachments = await draft.files.asyncCompactMap { fileUrl -> Attachment? in
                let file = File(url: fileUrl)
                guard let thumbnailURL = await file.getThumbnailURL() else {
                    return nil
                }
                guard let fullURL = await file.getURL() else {
                    return nil
                }
                return Attachment(id: UUID().uuidString, thumbnail: thumbnailURL, full: fullURL, type: .file)
            }
            
            return Message(id: id, user: user, status: status, createdAt: draft.createdAt, text: draft.text, attachments: attachments + fileAttachments, recording: draft.recording, replyMessage: draft.replyMessage)
        }
}

extension Message {
    var time: String {
        DateFormatter.timeFormatter.string(from: createdAt)
    }
}

extension Message: Equatable {
    public static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id &&
        lhs.user == rhs.user &&
        lhs.status == rhs.status &&
        lhs.createdAt == rhs.createdAt &&
        lhs.text == rhs.text &&
        lhs.attachments == rhs.attachments &&
        lhs.recording == rhs.recording &&
        lhs.replyMessage == rhs.replyMessage
    }
}

public struct Recording: Codable, Hashable {
    public var duration: Double
    public var waveformSamples: [CGFloat]
    public var url: URL?

    public init(duration: Double = 0.0, waveformSamples: [CGFloat] = [], url: URL? = nil) {
        self.duration = duration
        self.waveformSamples = waveformSamples
        self.url = url
    }
}

public struct ReplyMessage: Codable, Identifiable, Hashable {
    public static func == (lhs: ReplyMessage, rhs: ReplyMessage) -> Bool {
        lhs.id == rhs.id &&
        lhs.user == rhs.user &&
        lhs.createdAt == rhs.createdAt &&
        lhs.text == rhs.text &&
        lhs.attachments == rhs.attachments &&
        lhs.recording == rhs.recording
    }

    public var id: String
    public var user: User
    public var createdAt: Date

    public var text: String
    public var attachments: [Attachment]
    public var recording: Recording?

    public init(id: String,
                user: User,
                createdAt: Date,
                text: String = "",
                attachments: [Attachment] = [],
                recording: Recording? = nil) {

        self.id = id
        self.user = user
        self.createdAt = createdAt
        self.text = text
        self.attachments = attachments
        self.recording = recording
    }

    func toMessage() -> Message {
        Message(id: id, user: user, createdAt: createdAt, text: text, attachments: attachments, recording: recording)
    }
}

public extension Message {

    func toReplyMessage() -> ReplyMessage {
        ReplyMessage(id: id, user: user, createdAt: createdAt, text: text, attachments: attachments, recording: recording)
    }
}

public struct File: Identifiable, Equatable {
    public var id = UUID()
    public var url: URL
    public init(id: UUID = UUID(), url: URL) {
        self.id = id
        self.url = url
    }
    public static func == (lhs: File, rhs: File) -> Bool {
        lhs.id == rhs.id
    }
}
public extension File {

    func getURL() async -> URL? {
        url
    }

    public func getThumbnailURL() async -> URL? {
        do {
            return try await generateThumbnailFromFileAndSave(at: url, size: CGSize(width: 300, height: 300))
        } catch {
            print("error generating")
        }
        return nil
    }
}
func generateThumbnailFromFileAndSave(at url: URL, size: CGSize) async throws -> URL? {
    let request = await QLThumbnailGenerator.Request(fileAt: url, size: size, scale: UIScreen.main.scale, representationTypes: .thumbnail)

    // Specify the generic type explicitly for continuation
    let thumbnail: UIImage? = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<UIImage?, Error>) in
        QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { (thumbnail, error) in
            if let error = error {
                continuation.resume(throwing: error) // Resume with error if something went wrong
            } else if let thumbnail = thumbnail {
                continuation.resume(returning: thumbnail.uiImage) // Resume with the generated image
            } else {
                continuation.resume(returning: nil) // If no thumbnail is available, return nil
            }
        }
    }

    guard let thumbnailImage = thumbnail else {
        return nil
    }

    // Save the image to the temporary directory
    let tempDirectory = FileManager.default.temporaryDirectory
    let thumbnailURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")

    if let data = thumbnailImage.pngData() {
        try data.write(to: thumbnailURL)
        return thumbnailURL
    } else {
        return nil
    }
}
