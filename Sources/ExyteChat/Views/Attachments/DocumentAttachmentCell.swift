//
//  DocumentAttachmentCell.swift
//  ExyteChat
//
//  Created for file/document attachment display
//

import SwiftUI

/// A cell view for displaying document/file attachments (non-media)
struct DocumentAttachmentCell: View {
    
    @Environment(\.chatTheme) private var theme
    
    let attachment: Attachment
    let onTap: (Attachment) -> Void
    
    var body: some View {
        Button(action: { onTap(attachment) }) {
            HStack(spacing: 12) {
                // File icon
                fileIcon
                
                // File info
                VStack(alignment: .leading, spacing: 2) {
                    Text(attachment.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(theme.colors.mainText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if let sizeString = attachment.formattedFileSize {
                        Text(sizeString)
                            .font(.caption)
                            .foregroundColor(theme.colors.statusGray)
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(documentBackground)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Subviews
    
    private var fileIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(iconBackgroundColor)
                .frame(width: 44, height: 44)
            
            Image(systemName: attachment.iconName)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
        }
    }
    
    private var documentBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(theme.colors.inputBG.opacity(0.5))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme.colors.inputBG, lineWidth: 1)
            )
    }
    
    // MARK: - Colors
    
    private var iconBackgroundColor: Color {
        theme.colors.mainTint.opacity(0.15)
    }
    
    private var iconColor: Color {
        theme.colors.mainTint
    }
}

/// A compact version for inline display in messages
struct CompactDocumentCell: View {
    
    @Environment(\.chatTheme) private var theme
    
    let attachment: Attachment
    let onTap: (Attachment) -> Void
    
    var body: some View {
        Button(action: { onTap(attachment) }) {
            HStack(spacing: 8) {
                Image(systemName: attachment.iconName)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(attachment.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(theme.colors.mainText)
                        .lineLimit(1)
                    
                    if let sizeString = attachment.formattedFileSize {
                        Text(sizeString)
                            .font(.caption2)
                            .foregroundColor(theme.colors.statusGray)
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.colors.inputBG.opacity(0.3))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var iconColor: Color {
        theme.colors.mainTint
    }
}

#if DEBUG
struct DocumentAttachmentCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            DocumentAttachmentCell(
                attachment: Attachment(
                    id: "1",
                    url: URL(string: "https://example.com/test.pdf")!,
                    fileName: "Medical_Report_2024.pdf",
                    fileSize: 125_000,
                    mimeType: "application/pdf"
                ),
                onTap: { _ in }
            )
            
            DocumentAttachmentCell(
                attachment: Attachment(
                    id: "2",
                    url: URL(string: "https://example.com/test.docx")!,
                    fileName: "Prescription.docx",
                    fileSize: 45_000,
                    mimeType: "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                ),
                onTap: { _ in }
            )
            
            CompactDocumentCell(
                attachment: Attachment(
                    id: "3",
                    url: URL(string: "https://example.com/test.xlsx")!,
                    fileName: "Lab_Results.xlsx",
                    fileSize: 89_000,
                    mimeType: nil
                ),
                onTap: { _ in }
            )
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
#endif
