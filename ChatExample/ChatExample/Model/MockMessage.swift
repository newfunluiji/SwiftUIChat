//
//  Created by Alex.M on 27.06.2022.
//

import Foundation
import ExyteChat

struct MockMessage: Sendable {
    let uid: String
    let sender: MockUser
    let createdAt: Date
    var status: Message.Status?
    var messageType: MessageType

    let text: String
    let images: [MockImage]
    let videos: [MockVideo]
    let files: [MockFile]
    let reactions: [Reaction]
    let recording: Recording?
    let replyMessage: ReplyMessage?
    var uploadProgress: Double?
    
    init(
        uid: String,
        sender: MockUser,
        createdAt: Date,
        status: Message.Status? = nil,
        messageType: MessageType = .regular,
        text: String,
        images: [MockImage] = [],
        videos: [MockVideo] = [],
        files: [MockFile] = [],
        reactions: [Reaction] = [],
        recording: Recording? = nil,
        replyMessage: ReplyMessage? = nil,
        uploadProgress: Double? = nil
    ) {
        self.uid = uid
        self.sender = sender
        self.createdAt = createdAt
        self.status = status
        self.messageType = messageType
        self.text = text
        self.images = images
        self.videos = videos
        self.files = files
        self.reactions = reactions
        self.recording = recording
        self.replyMessage = replyMessage
        self.uploadProgress = uploadProgress
    }
}

/// Model for file attachments in mock messages
struct MockFile: Sendable {
    let id: String
    let url: URL
    let fileName: String
    let fileSize: Int64?
    let mimeType: String?
    
    func toChatAttachment() -> ExyteChat.Attachment {
        Attachment(
            id: id,
            url: url,
            type: .document,
            fileName: fileName,
            fileSize: fileSize,
            mimeType: mimeType
        )
    }
}

extension MockMessage {
    func toChatMessage() -> ExyteChat.Message {
        ExyteChat.Message(
            id: uid,
            user: sender.toChatUser(),
            status: status,
            createdAt: createdAt,
            text: text,
            attachments: images.map { $0.toChatAttachment() } + videos.map { $0.toChatAttachment() } + files.map { $0.toChatAttachment() },
            reactions: reactions,
            recording: recording,
            replyMessage: replyMessage,
            messageType: messageType,
            uploadProgress: uploadProgress
        )
    }
    
    /// Creates a system message
    static func systemMessage(text: String, date: Date = Date()) -> MockMessage {
        MockMessage(
            uid: UUID().uuidString,
            sender: MockUser(uid: "system", name: "System"),
            createdAt: date,
            status: nil,
            messageType: .system(text),
            text: "",
            images: [],
            videos: [],
            files: [],
            reactions: [],
            recording: nil,
            replyMessage: nil,
            uploadProgress: nil
        )
    }
}
