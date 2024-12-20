//
//  Created by Alex.M on 14.06.2022.
//

import SwiftUI

struct TextInputView: View {

    @Environment(\.chatTheme) private var theme

    @EnvironmentObject private var globalFocusState: GlobalFocusState

    @Binding var text: String
    var inputFieldId: UUID
    var style: InputViewStyle
    var availableInput: AvailableInputType

    var body: some View {
        TextField("", text: $text, axis: .vertical)
            .customFocus($globalFocusState.focus, equals: .uuid(inputFieldId))
            .placeholder(when: text.isEmpty) {
                Text(LocalizedStringKey(style.placeholder))
                    .foregroundColor(Color(red: 1 / 255, green: 22 / 255, blue: 39 / 255, opacity: 1.0))
            }
            .foregroundColor(style == .message ? .black : theme.colors.textDarkContext)
            .padding(.vertical, 10)
            .padding(.leading, availableInput == .textAndAudio ? 12 : 0)
            .onTapGesture {
                globalFocusState.focus = .uuid(inputFieldId)
            }
            .textSelection(.enabled)
            .padding(.leading)

    }
}
