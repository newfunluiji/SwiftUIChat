//
//  DocumentPreviewController.swift
//  ExyteChat
//
//  Created for QuickLook document preview integration
//

import SwiftUI
import QuickLook

/// SwiftUI wrapper for QLPreviewController to preview documents
public struct DocumentPreviewController: UIViewControllerRepresentable {
    
    let url: URL
    @Binding var isPresented: Bool
    
    public init(url: URL, isPresented: Binding<Bool>) {
        self.url = url
        self._isPresented = isPresented
    }
    
    public func makeUIViewController(context: Context) -> UINavigationController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        
        let navController = UINavigationController(rootViewController: controller)
        return navController
    }
    
    public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Update if needed
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
        let parent: DocumentPreviewController
        var localFileURL: URL?
        var downloadTask: URLSessionDownloadTask?
        
        init(_ parent: DocumentPreviewController) {
            self.parent = parent
            super.init()
            prepareFile()
        }
        
        deinit {
            downloadTask?.cancel()
            // Clean up temp file if needed
            if let localURL = localFileURL, localURL != parent.url {
                try? FileManager.default.removeItem(at: localURL)
            }
        }
        
        private func prepareFile() {
            // If it's a local file, use it directly
            if parent.url.isFileURL {
                localFileURL = parent.url
                return
            }
            
            // For remote URLs, check cache or download
            let cacheDir = FileManager.default.temporaryDirectory
            let fileName = parent.url.lastPathComponent
            let cachedURL = cacheDir.appendingPathComponent(fileName)
            
            // Check if already cached
            if FileManager.default.fileExists(atPath: cachedURL.path) {
                localFileURL = cachedURL
                return
            }
            
            // Download the file
            downloadFile(to: cachedURL)
        }
        
        private func downloadFile(to destination: URL) {
            downloadTask = URLSession.shared.downloadTask(with: parent.url) { [weak self] tempURL, response, error in
                guard let self = self, let tempURL = tempURL, error == nil else {
                    print("DocumentPreview: Failed to download file: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                do {
                    // Remove existing file if any
                    try? FileManager.default.removeItem(at: destination)
                    // Move downloaded file to cache location
                    try FileManager.default.moveItem(at: tempURL, to: destination)
                    
                    DispatchQueue.main.async {
                        self.localFileURL = destination
                        // Refresh the preview controller
                        if let navController = UIApplication.shared.windows.first?.rootViewController?.presentedViewController as? UINavigationController,
                           let previewController = navController.viewControllers.first as? QLPreviewController {
                            previewController.reloadData()
                        }
                    }
                } catch {
                    print("DocumentPreview: Failed to save file: \(error)")
                }
            }
            downloadTask?.resume()
        }
        
        // MARK: - QLPreviewControllerDataSource
        
        public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return localFileURL != nil ? 1 : 0
        }
        
        public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return (localFileURL ?? parent.url) as NSURL
        }
        
        // MARK: - QLPreviewControllerDelegate
        
        public func previewControllerWillDismiss(_ controller: QLPreviewController) {
            parent.isPresented = false
        }
    }
}

/// A simpler approach using a sheet modifier
public struct DocumentPreviewSheet: ViewModifier {
    
    let url: URL?
    @Binding var isPresented: Bool
    
    public func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                if let url = url {
                    DocumentPreviewController(url: url, isPresented: $isPresented)
                        .edgesIgnoringSafeArea(.all)
                }
            }
    }
}

public extension View {
    /// Present a document preview sheet
    func documentPreview(url: URL?, isPresented: Binding<Bool>) -> some View {
        modifier(DocumentPreviewSheet(url: url, isPresented: isPresented))
    }
}

/// A view that handles document preview with automatic file downloading
public struct DocumentPreviewView: View {
    
    @Environment(\.chatTheme) private var theme
    
    let attachment: Attachment
    @Binding var isPresented: Bool
    
    @State private var localURL: URL?
    @State private var isDownloading = false
    @State private var downloadProgress: Double = 0
    @State private var error: String?
    
    public var body: some View {
        ZStack {
            if let localURL = localURL {
                DocumentPreviewController(url: localURL, isPresented: $isPresented)
            } else if isDownloading {
                downloadingView
            } else if let error = error {
                errorView(message: error)
            } else {
                Color.clear
                    .onAppear {
                        prepareFile()
                    }
            }
        }
    }
    
    private var downloadingView: some View {
        VStack(spacing: 16) {
            CircularProgressView(progress: downloadProgress, lineWidth: 6, size: 60)
            
            Text("Downloading...")
                .font(.headline)
                .foregroundColor(theme.colors.mainText)
            
            Text(attachment.displayName)
                .font(.subheadline)
                .foregroundColor(theme.colors.statusGray)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            Button("Cancel") {
                isPresented = false
            }
            .foregroundColor(theme.colors.mainTint)
        }
        .padding()
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Failed to load document")
                .font(.headline)
                .foregroundColor(theme.colors.mainText)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(theme.colors.statusGray)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                Button("Retry") {
                    error = nil
                    prepareFile()
                }
                .foregroundColor(theme.colors.mainTint)
                
                Button("Close") {
                    isPresented = false
                }
                .foregroundColor(theme.colors.statusGray)
            }
        }
        .padding()
    }
    
    private func prepareFile() {
        let url = attachment.full
        
        // Local file - use directly
        if url.isFileURL {
            localURL = url
            return
        }
        
        // Check cache
        let cacheDir = FileManager.default.temporaryDirectory
        let fileName = attachment.fileName ?? url.lastPathComponent
        let cachedURL = cacheDir.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: cachedURL.path) {
            localURL = cachedURL
            return
        }
        
        // Download
        isDownloading = true
        downloadProgress = 0
        
        let task = URLSession.shared.downloadTask(with: url) { tempURL, response, downloadError in
            DispatchQueue.main.async {
                isDownloading = false
                
                guard let tempURL = tempURL, downloadError == nil else {
                    error = downloadError?.localizedDescription ?? "Download failed"
                    return
                }
                
                do {
                    try? FileManager.default.removeItem(at: cachedURL)
                    try FileManager.default.moveItem(at: tempURL, to: cachedURL)
                    localURL = cachedURL
                } catch {
                    self.error = "Failed to save file"
                }
            }
        }
        
        // Observe progress
        let observation = task.progress.observe(\.fractionCompleted) { progress, _ in
            DispatchQueue.main.async {
                downloadProgress = progress.fractionCompleted
            }
        }
        
        // Store observation to prevent deallocation
        withExtendedLifetime(observation) {
            task.resume()
        }
    }
}

#if DEBUG
struct DocumentPreviewController_Previews: PreviewProvider {
    static var previews: some View {
        Text("Document Preview")
            .documentPreview(
                url: URL(string: "https://example.com/sample.pdf"),
                isPresented: .constant(true)
            )
    }
}
#endif
