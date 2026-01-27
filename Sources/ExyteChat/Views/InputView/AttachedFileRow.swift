//
//  AttachedFileRow.swift
//  ExyteChat
//
//  Created for displaying pending file attachments in input view
//

import SwiftUI

/// Row displaying a pending file attachment with remove button
struct AttachedFileRow: View {
    
    @Environment(\.chatTheme) private var theme
    
    let file: FileAttachment
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            // File icon
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(iconBackgroundColor)
                    .frame(width: 36, height: 36)
                
                Image(systemName: file.iconName)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }
            
            // File info
            VStack(alignment: .leading, spacing: 2) {
                Text(file.fileName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(theme.colors.mainText)
                    .lineLimit(1)
                
                if let sizeString = file.formattedFileSize {
                    Text(sizeString)
                        .font(.caption)
                        .foregroundColor(theme.colors.statusGray)
                }
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
    }
    
    // MARK: - Colors
    
    private var iconBackgroundColor: Color {
        theme.colors.mainTint.opacity(0.15)
    }
    
    private var iconColor: Color {
        theme.colors.mainTint
    }
}

/// Container view for multiple attached files
struct AttachedFilesContainer: View {
    
    let files: [FileAttachment]
    let onRemove: (String) -> Void
    
    var body: some View {
        if !files.isEmpty {
            VStack(spacing: 8) {
                ForEach(files) { file in
                    AttachedFileRow(file: file) {
                        onRemove(file.id)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
}

/// Compact file attachment indicator (for showing count)
struct AttachedFilesIndicator: View {
    
    @Environment(\.chatTheme) private var theme
    
    let count: Int
    let onTap: () -> Void
    
    var body: some View {
        if count > 0 {
            Button(action: onTap) {
                HStack(spacing: 4) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 14))
                    
                    Text("\(count)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(theme.colors.mainTint)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(theme.colors.mainTint.opacity(0.15))
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#if DEBUG
struct AttachedFileRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            AttachedFileRow(
                file: FileAttachment(
                    url: URL(string: "file:///test.pdf")!,
                    fileName: "Medical_Report_2024.pdf",
                    fileSize: 125_000,
                    mimeType: "application/pdf"
                ),
                onRemove: {}
            )
            
            AttachedFileRow(
                file: FileAttachment(
                    url: URL(string: "file:///test.docx")!,
                    fileName: "Very_Long_Filename_That_Should_Be_Truncated.docx",
                    fileSize: 45_000,
                    mimeType: nil
                ),
                onRemove: {}
            )
            
            AttachedFilesContainer(
                files: [
                    FileAttachment(
                        url: URL(string: "file:///test1.pdf")!,
                        fileName: "Document1.pdf",
                        fileSize: 100_000
                    ),
                    FileAttachment(
                        url: URL(string: "file:///test2.xlsx")!,
                        fileName: "Spreadsheet.xlsx",
                        fileSize: 50_000
                    )
                ],
                onRemove: { _ in }
            )
            
            AttachedFilesIndicator(count: 3, onTap: {})
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
#endif
