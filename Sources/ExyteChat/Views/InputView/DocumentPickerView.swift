//
//  DocumentPickerView.swift
//  ExyteChat
//
//  Created for file/document picking functionality
//

import SwiftUI
import UniformTypeIdentifiers

/// SwiftUI wrapper for UIDocumentPickerViewController
public struct DocumentPickerView: UIViewControllerRepresentable {
    
    /// Allowed document types
    let allowedTypes: [UTType]
    
    /// Whether multiple selection is allowed
    let allowsMultipleSelection: Bool
    
    /// Callback when files are picked
    let onPick: ([URL]) -> Void
    
    /// Callback when picker is cancelled
    let onCancel: (() -> Void)?
    
    public init(
        allowedTypes: [UTType] = DocumentPickerView.defaultTypes,
        allowsMultipleSelection: Bool = true,
        onPick: @escaping ([URL]) -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        self.allowedTypes = allowedTypes
        self.allowsMultipleSelection = allowsMultipleSelection
        self.onPick = onPick
        self.onCancel = onCancel
    }
    
    /// Default supported document types
    public static var defaultTypes: [UTType] {
        [
            .pdf,
            .png,
            .jpeg,
            .heic,
            .gif,
            .plainText,
            .rtf,
            .data,
            .content,
            UTType("com.microsoft.word.doc"),
            UTType("org.openxmlformats.wordprocessingml.document"),
            UTType("com.microsoft.excel.xls"),
            UTType("org.openxmlformats.spreadsheetml.sheet"),
            UTType("com.microsoft.powerpoint.ppt"),
            UTType("org.openxmlformats.presentationml.presentation")
        ].compactMap { $0 }
    }
    
    /// Document types only (no images/videos)
    public static var documentOnlyTypes: [UTType] {
        [
            .pdf,
            .plainText,
            .rtf,
            UTType("com.microsoft.word.doc"),
            UTType("org.openxmlformats.wordprocessingml.document"),
            UTType("com.microsoft.excel.xls"),
            UTType("org.openxmlformats.spreadsheetml.sheet"),
            UTType("com.microsoft.powerpoint.ppt"),
            UTType("org.openxmlformats.presentationml.presentation")
        ].compactMap { $0 }
    }
    
    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes)
        picker.allowsMultipleSelection = allowsMultipleSelection
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No updates needed
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerView
        
        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }
        
        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            // Copy files to app's temp directory to ensure access
            let tempDirectory = FileManager.default.temporaryDirectory
            var copiedURLs: [URL] = []
            
            for url in urls {
                // Start accessing the security-scoped resource
                guard url.startAccessingSecurityScopedResource() else {
                    print("DocumentPicker: Failed to access security-scoped resource for \(url)")
                    continue
                }
                
                defer {
                    url.stopAccessingSecurityScopedResource()
                }
                
                let fileName = url.lastPathComponent
                let destURL = tempDirectory.appendingPathComponent(UUID().uuidString + "-" + fileName)
                
                do {
                    // Remove existing file if any
                    try? FileManager.default.removeItem(at: destURL)
                    // Copy file to temp directory
                    try FileManager.default.copyItem(at: url, to: destURL)
                    copiedURLs.append(destURL)
                } catch {
                    print("DocumentPicker: Failed to copy file: \(error)")
                }
            }
            
            parent.onPick(copiedURLs)
        }
        
        public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.onCancel?()
        }
    }
}

/// View modifier for presenting document picker as a sheet
public struct DocumentPickerSheetModifier: ViewModifier {
    
    @Binding var isPresented: Bool
    let allowedTypes: [UTType]
    let allowsMultipleSelection: Bool
    let onPick: ([URL]) -> Void
    
    public func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                DocumentPickerView(
                    allowedTypes: allowedTypes,
                    allowsMultipleSelection: allowsMultipleSelection,
                    onPick: { urls in
                        isPresented = false
                        onPick(urls)
                    },
                    onCancel: {
                        isPresented = false
                    }
                )
            }
    }
}

public extension View {
    /// Present a document picker sheet
    func documentPicker(
        isPresented: Binding<Bool>,
        allowedTypes: [UTType] = DocumentPickerView.defaultTypes,
        allowsMultipleSelection: Bool = true,
        onPick: @escaping ([URL]) -> Void
    ) -> some View {
        modifier(DocumentPickerSheetModifier(
            isPresented: isPresented,
            allowedTypes: allowedTypes,
            allowsMultipleSelection: allowsMultipleSelection,
            onPick: onPick
        ))
    }
}

#if DEBUG
struct DocumentPickerView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Document Picker Preview")
            .documentPicker(isPresented: .constant(false)) { urls in
                print("Picked: \(urls)")
            }
    }
}
#endif
