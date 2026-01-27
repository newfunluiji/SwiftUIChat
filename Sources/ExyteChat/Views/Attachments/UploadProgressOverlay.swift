//
//  UploadProgressOverlay.swift
//  ExyteChat
//
//  Created for upload progress display in attachment cells
//

import SwiftUI

/// Overlay view showing upload progress on attachments
struct UploadProgressOverlay: View {
    
    @Environment(\.chatTheme) private var theme
    
    /// Progress value from 0.0 to 1.0, nil means indeterminate
    let progress: Double?
    
    /// Whether to show the overlay
    let isUploading: Bool
    
    var body: some View {
        if isUploading {
            ZStack {
                // Semi-transparent background
                Color.black.opacity(0.4)
                
                // Progress indicator
                if let progress = progress, progress >= 0 && progress < 1.0 {
                    // Determinate progress
                    CircularProgressView(progress: progress)
                } else {
                    // Indeterminate loading
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                }
            }
        }
    }
}

/// Circular progress indicator with percentage
struct CircularProgressView: View {
    
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    let showPercentage: Bool
    
    init(progress: Double, lineWidth: CGFloat = 4, size: CGFloat = 44, showPercentage: Bool = true) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.size = size
        self.showPercentage = showPercentage
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: lineWidth)
            
            // Progress arc
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(Color.white, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)
            
            // Percentage text
            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size * 0.28, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .frame(width: size, height: size)
    }
}

/// Horizontal progress bar for inline display
struct HorizontalProgressBar: View {
    
    @Environment(\.chatTheme) private var theme
    
    let progress: Double?
    let height: CGFloat
    
    init(progress: Double?, height: CGFloat = 4) {
        self.progress = progress
        self.height = height
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.white.opacity(0.3))
                
                // Progress
                if let progress = progress, progress >= 0 && progress <= 1.0 {
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(theme.colors.mainTint)
                        .frame(width: geometry.size.width * CGFloat(progress))
                        .animation(.linear(duration: 0.1), value: progress)
                } else {
                    // Indeterminate animation
                    IndeterminateProgressBar(height: height)
                }
            }
        }
        .frame(height: height)
    }
}

/// Indeterminate progress bar with moving indicator
struct IndeterminateProgressBar: View {
    
    @State private var offset: CGFloat = -1.0
    let height: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: height / 2)
                .fill(Color.white)
                .frame(width: geometry.size.width * 0.3)
                .offset(x: (offset + 1) * geometry.size.width * 0.35)
                .animation(
                    Animation.linear(duration: 1.0).repeatForever(autoreverses: true),
                    value: offset
                )
                .onAppear {
                    offset = 1.0
                }
        }
        .frame(height: height)
        .clipped()
    }
}

/// Upload status badge for message status
struct UploadStatusBadge: View {
    
    @Environment(\.chatTheme) private var theme
    
    let progress: Double?
    let status: Message.Status?
    
    var body: some View {
        if let progress = progress, progress < 1.0 {
            HStack(spacing: 4) {
                CircularProgressView(progress: progress, lineWidth: 2, size: 14, showPercentage: false)
                Text("\(Int(progress * 100))%")
                    .font(.caption2)
                    .foregroundColor(theme.colors.statusGray)
            }
        } else if status == .sending {
            HStack(spacing: 4) {
                ProgressView()
                    .scaleEffect(0.6)
                Text("Sending...")
                    .font(.caption2)
                    .foregroundColor(theme.colors.statusGray)
            }
        }
    }
}

#if DEBUG
struct UploadProgressOverlay_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Determinate progress
            ZStack {
                Color.gray
                    .frame(width: 100, height: 100)
                UploadProgressOverlay(progress: 0.65, isUploading: true)
            }
            .cornerRadius(12)
            
            // Indeterminate progress
            ZStack {
                Color.gray
                    .frame(width: 100, height: 100)
                UploadProgressOverlay(progress: nil, isUploading: true)
            }
            .cornerRadius(12)
            
            // Circular progress standalone
            CircularProgressView(progress: 0.45)
                .background(Color.gray)
            
            // Horizontal progress bar
            HorizontalProgressBar(progress: 0.7)
                .frame(width: 200)
                .padding()
                .background(Color.gray.opacity(0.3))
            
            // Indeterminate horizontal
            HorizontalProgressBar(progress: nil)
                .frame(width: 200)
                .padding()
                .background(Color.gray.opacity(0.3))
        }
        .padding()
    }
}
#endif
