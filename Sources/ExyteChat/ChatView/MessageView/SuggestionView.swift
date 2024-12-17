//
//  MessageView.swift
//  Chat
//
//  Created by Anton Atanasov on 16.05.24.
//

import SwiftUI

struct SuggestionView: View {
    @Environment(\.chatTheme) private var theme
    @ObservedObject var viewModel: ChatViewModel
    let suggestion: Suggestion
    let tapSuggestionClosure: ChatView.TapSuggestionClosure?
    let messageUseMarkdown: Bool
    var font: UIFont
    var themeView: SuggestionViewTheme = .default 

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .center, spacing: 0) {
                bubbleView(suggestion)
                    .onTapGesture {
                        tapSuggestionClosure?(suggestion)
                    }
                    .padding(.top, themeView.verticalPadding)
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width, alignment: .center)
    }

    @ViewBuilder
    func bubbleView(_ suggestion: Suggestion) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if !suggestion.label.isEmpty {
                let messageView = MessageTextView(text: suggestion.label, messageUseMarkdown: messageUseMarkdown)
                    .fixedSize(horizontal: false, vertical: false)
                    .padding(themeView.messagePadding)
                Spacer()
                HStack(alignment: .lastTextBaseline, spacing: themeView.bubbleSpacing) {
                    Spacer()
                    messageView
                    Spacer()
                }
                .padding(.horizontal, themeView.horizontalPadding)
                .padding(.vertical, themeView.verticalPadding)
                .font(Font(font))
                .background(theme.colors.mainBackground)
                Spacer()
            }
        }
        .bubbleBackground(suggestion, theme: theme, cornerRadius: themeView.bubbleCornerRadius)
    }
}

extension View {
    @ViewBuilder
    func bubbleBackground(_ suggestion: Suggestion, theme: ChatTheme, cornerRadius: CGFloat) -> some View {
        self
            .foregroundColor(theme.colors.textDarkContext)
            .background {
                if !suggestion.label.isEmpty {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .foregroundColor(.clear)
                        .opacity(1)
                }
            }
            .cornerRadius(cornerRadius)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.gray, lineWidth: 1)
            }
    }
}

#if DEBUG
struct SuggestionView_Preview: PreviewProvider {
    
    static private var suggestionMessage = "Some suggestion text to send with long text to display."    
    static private var suggestionMessage1 = "Some short suggestion."
    static private var suggestionMessage2 = "Some short suggestion again."
    static private var suggestionMessage3 = "Some suggestion text to send with long text to display."
    static private var suggestion = Suggestion(
        id: UUID().uuidString,
        label: suggestionMessage,
        value: suggestionMessage
    )
    static private var suggestion1 = Suggestion(
        id: UUID().uuidString,
        label: suggestionMessage1,
        value: suggestionMessage1
    )
    static private var suggestion2 = Suggestion(
        id: UUID().uuidString,
        label: suggestionMessage2,
        value: suggestionMessage2
    )
    static private var suggestion3 = Suggestion(
        id: UUID().uuidString,
        label: suggestionMessage3,
        value: suggestionMessage3
    )

    static private var suggestions = [suggestion, suggestion1, suggestion2, suggestion3]
    static var previews: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 2), GridItem(.adaptive(minimum: 180), spacing: 2)]) {
                ForEach((suggestions), id: \.self) {
                    SuggestionView(
                        viewModel: ChatViewModel(),
                        suggestion: $0,
                        tapSuggestionClosure: nil,
                        messageUseMarkdown: true,
                        font: UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 15))
                    )
                }
            }
        }
    }
}
#endif
