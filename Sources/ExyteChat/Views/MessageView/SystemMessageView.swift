//
//  SystemMessageView.swift
//  ExyteChat
//
//  Created for system message display (e.g., "User joined the chat")
//

import SwiftUI

/// View for displaying system messages (centered, no bubble, no avatar)
public struct SystemMessageView: View {
    
    @Environment(\.chatTheme) private var theme
    
    let text: String
    let date: Date?
    
    public init(text: String, date: Date? = nil) {
        self.text = text
        self.date = date
    }
    
    public var body: some View {
        VStack(spacing: 4) {
            HStack {
                line
                
                Text(text)
                    .font(.caption)
                    .foregroundColor(theme.colors.statusGray)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                line
            }
            .padding(.horizontal, 16)
            
            if let date = date {
                Text(DateFormatter.timeFormatter.string(from: date))
                    .font(.caption2)
                    .foregroundColor(theme.colors.statusGray.opacity(0.7))
            }
        }
        .padding(.vertical, 8)
    }
    
    private var line: some View {
        Rectangle()
            .fill(theme.colors.statusGray.opacity(0.3))
            .frame(height: 1)
    }
}

/// System message with just text (simpler style)
public struct SimpleSystemMessageView: View {
    
    @Environment(\.chatTheme) private var theme
    
    let text: String
    
    public init(text: String) {
        self.text = text
    }
    
    public var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(theme.colors.statusGray)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(theme.colors.inputBG.opacity(0.5))
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
    }
}

/// Date separator view for chat
public struct DateSeparatorView: View {
    
    @Environment(\.chatTheme) private var theme
    
    let date: Date
    
    public init(date: Date) {
        self.date = date
    }
    
    public var body: some View {
        HStack {
            line
            
            Text(formattedDate)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(theme.colors.statusGray)
                .padding(.horizontal, 12)
            
            line
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private var line: some View {
        Rectangle()
            .fill(theme.colors.statusGray.opacity(0.3))
            .frame(height: 1)
    }
    
    private var formattedDate: String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    }
}

/// Unread messages separator
public struct UnreadMessagesSeparatorView: View {
    
    @Environment(\.chatTheme) private var theme
    
    let text: String
    
    public init(text: String = "Unread messages") {
        self.text = text
    }
    
    public var body: some View {
        HStack {
            line
            
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(theme.colors.mainTint)
                .padding(.horizontal, 12)
            
            line
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private var line: some View {
        Rectangle()
            .fill(theme.colors.mainTint.opacity(0.5))
            .frame(height: 1)
    }
}

#if DEBUG
struct SystemMessageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SystemMessageView(text: "Anton Atanasov joined the conversation", date: Date())
            
            SimpleSystemMessageView(text: "Consultation ended")
            
            DateSeparatorView(date: Date())
            
            DateSeparatorView(date: Date().addingTimeInterval(-86400)) // Yesterday
            
            DateSeparatorView(date: Date().addingTimeInterval(-86400 * 5)) // 5 days ago
            
            UnreadMessagesSeparatorView()
            
            UnreadMessagesSeparatorView(text: "Непрочетени съобщения")
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
#endif
