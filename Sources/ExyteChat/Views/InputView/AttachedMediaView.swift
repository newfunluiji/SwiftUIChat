//
//  AttachedMediaView.swift
//  ExyteChat
//
//  Created for displaying pending media attachments (images) in input view
//

import SwiftUI
import ExyteMediaPicker

/// Row displaying a pending media attachment with small thumbnail and remove button
struct AttachedMediaRow: View {
    
    @Environment(\.chatTheme) private var theme
    
    let media: Media
    let onRemove: () -> Void
    
    @State private var thumbnailURL: URL?
    
    private let thumbnailSize: CGFloat = 36
    
    var body: some View {
        HStack(spacing: 10) {
            // Thumbnail
            Group {
                if let url = thumbnailURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            placeholderView
                        case .empty:
                            ProgressView()
                                .frame(width: thumbnailSize, height: thumbnailSize)
                        @unknown default:
                            placeholderView
                        }
                    }
                } else {
                    placeholderView
                }
            }
            .frame(width: thumbnailSize, height: thumbnailSize)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            // File info
            VStack(alignment: .leading, spacing: 2) {
                Text("Photo")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.colors.mainText)
                    .lineLimit(1)
                
                Text("Image")
                    .font(.caption)
                    .foregroundColor(theme.colors.statusGray)
            }
            
            Spacer()
            
            // Remove button
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(theme.colors.statusGray)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(theme.colors.inputBG)
        )
        .task {
            thumbnailURL = await media.getThumbnailURL()
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(theme.colors.mainTint.opacity(0.15))
            Image(systemName: "photo")
                .font(.system(size: 16))
                .foregroundColor(theme.colors.mainTint)
        }
        .frame(width: thumbnailSize, height: thumbnailSize)
    }
}

/// Container view for multiple attached media items (vertical list like files)
struct AttachedMediaView: View {
    
    let medias: [Media]
    let onRemove: (String) -> Void
    
    var body: some View {
        if !medias.isEmpty {
            VStack(spacing: 8) {
                ForEach(medias, id: \.id) { media in
                    AttachedMediaRow(media: media) {
                        onRemove(media.id.uuidString)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
}

#if DEBUG
struct AttachedMediaView_Previews: PreviewProvider {
    static var previews: some View {
        AttachedMediaView(medias: []) { _ in }
    }
}
#endif
