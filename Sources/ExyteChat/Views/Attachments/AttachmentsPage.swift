//
//  Created by Alex.M on 20.06.2022.
//

import SwiftUI
import PDFKit

struct AttachmentsPage: View {

    @EnvironmentObject var mediaPagesViewModel: FullscreenMediaPagesViewModel
    @Environment(\.chatTheme) private var theme

    let attachment: Attachment

    var body: some View {
        if attachment.type == .image {
            CachedAsyncImage(url: attachment.full, urlCache: .imageCache) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                default:
                    ActivityIndicator()
                }
            }
        } else if attachment.type == .video {
            VideoView(viewModel: VideoViewModel(attachment: attachment))
        } else if attachment.type == .document {
            // Document type - check if PDF for preview, otherwise show placeholder
            if attachment.fileExtension?.lowercased() == "pdf" {
                PDFPreviewView(url: attachment.full)
            } else {
                documentPlaceholderView
            }
        } else if attachment.type == .file {
            // Generic file - try thumbnail first, then placeholder
            if let thumbnail = attachment.thumbnail {
                CachedAsyncImage(url: thumbnail, urlCache: .imageCache) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    default:
                        documentPlaceholderView
                    }
                }
            } else {
                documentPlaceholderView
            }
        } else {
            Rectangle()
                .foregroundColor(Color.gray)
                .frame(minWidth: 100, minHeight: 100)
                .frame(maxHeight: 200)
                .overlay {
                    Text("Unknown", bundle: .module)
                }
        }
    }
    
    // MARK: - Document Placeholder
    
    private var documentPlaceholderView: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(iconBackgroundColor)
                    .frame(width: 100, height: 100)
                
                Image(systemName: attachment.iconName)
                    .font(.system(size: 44))
                    .foregroundColor(iconColor)
            }
            
            VStack(spacing: 4) {
                Text(attachment.displayName)
                    .font(.headline)
                    .foregroundColor(theme.colors.mainText)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                
                if let sizeString = attachment.formattedFileSize {
                    Text(sizeString)
                        .font(.subheadline)
                        .foregroundColor(theme.colors.statusGray)
                }
            }
            .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var iconBackgroundColor: Color {
        switch attachment.fileExtension?.lowercased() {
        case "pdf":
            return Color.red.opacity(0.15)
        case "doc", "docx":
            return Color.blue.opacity(0.15)
        case "xls", "xlsx":
            return Color.green.opacity(0.15)
        case "ppt", "pptx":
            return Color.orange.opacity(0.15)
        default:
            return theme.colors.inputBG
        }
    }
    
    private var iconColor: Color {
        switch attachment.fileExtension?.lowercased() {
        case "pdf":
            return Color.red
        case "doc", "docx":
            return Color.blue
        case "xls", "xlsx":
            return Color.green
        case "ppt", "pptx":
            return Color.orange
        default:
            return theme.colors.mainTint
        }
    }
}

// MARK: - PDF Preview

struct PDFPreviewView: View {
    let url: URL
    
    var body: some View {
        PDFKitView(url: url)
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        
        // Load PDF from URL
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        // Update if URL changes
        if uiView.document?.documentURL != url {
            if let document = PDFDocument(url: url) {
                uiView.document = document
            }
        }
    }
}
