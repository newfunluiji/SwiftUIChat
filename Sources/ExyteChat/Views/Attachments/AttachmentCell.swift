//
//  Created by Alex.M on 16.06.2022.
//

import SwiftUI

public struct AttachmentCell: View {

    @Environment(\.chatTheme) var theme

    let attachment: Attachment
    let size: CGSize
    let onTap: (Attachment) -> Void

    public init(attachment: Attachment, size: CGSize, onTap: @escaping (Attachment) -> Void) {
        self.attachment = attachment
        self.size = size
        self.onTap = onTap
    }

    public var body: some View {
        Group {
            if attachment.type == .image {
                mediaContent
            } else if attachment.type == .video {
                mediaContent
                    .overlay {
                        theme.images.message.playVideo
                            .resizable()
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                    }
            } else if attachment.type == .document {
                // Document attachment - show icon + file info
                DocumentAttachmentCell(attachment: attachment, onTap: onTap)
            } else if attachment.type == .file {
                // Generic file - try to show thumbnail if available, otherwise show icon
                if attachment.thumbnail != nil {
                    mediaContent
                } else {
                    DocumentAttachmentCell(attachment: attachment, onTap: onTap)
                }
            } else {
                mediaContent
                    .overlay {
                        Text("Unknown", bundle: .module)
                    }
            }
        }
        .frame(width: size.width, height: size.height)
        .overlay {
            // Upload progress overlay
            if attachment.isUploading {
                UploadProgressOverlay(
                    progress: attachment.uploadProgress,
                    isUploading: true
                )
                .cornerRadius(12)
            }
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded {
                onTap(attachment)
            }
        )
    }

    var mediaContent: some View {
        Group {
            if let thumbnailURL = attachment.thumbnail {
                AsyncImageView(url: thumbnailURL, size: size)
            } else {
                // Fallback for attachments without thumbnail
                ZStack {
                    Rectangle()
                        .foregroundColor(theme.colors.inputBG)
                    Image(systemName: attachment.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(theme.colors.mainTint)
                }
            }
        }
    }
}

struct AsyncImageView: View {

    @Environment(\.chatTheme) var theme

    let url: URL
    let size: CGSize

    var body: some View {
        CachedAsyncImage(url: url, urlCache: .imageCache) { imageView in
            imageView
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height)
                .clipped()
        } placeholder: {
            ZStack {
                Rectangle()
                    .foregroundColor(theme.colors.inputBG)
                    .frame(width: size.width, height: size.height)
                ActivityIndicator(size: 30, showBackground: false)
            }
        }
//        .background(theme.colors.grayStatus)
    }
}
