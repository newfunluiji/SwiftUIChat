//
//  InputView.swift
//  Chat
//
//  Created by Alex.M on 25.05.2022.
//

import SwiftUI
import ExyteMediaPicker

public enum InputViewStyle {
    case message
    case signature

    var placeholder: String {
        switch self {
        case .message:
            return "Type a message..."
        case .signature:
            return "Add signature..."
        }
    }
}

public enum InputViewAction {
    case photo
    case add
    case camera
    case send

    case recordAudioHold
    case recordAudioTap
    case recordAudioLock
    case stopRecordAudio
    case deleteRecord
    case playRecord
    case pauseRecord
    case document
    //    case location
    //    case document
}

public enum InputViewState {
    case empty
    case hasTextOrMedia

    case waitingForRecordingPermission
    case isRecordingHold
    case isRecordingTap
    case hasRecording
    case playingRecording
    case pausedRecording

    var canSend: Bool {
        switch self {
        case .hasTextOrMedia, .hasRecording, .isRecordingTap, .playingRecording, .pausedRecording: return true
        default: return false
        }
    }
}

public enum AvailableInputType {
    case full // Camera + attachments + text + audio
    case textAndAudio
}

public struct InputViewAttachments {
    public var text: String = ""
    public var medias: [Media] = []
    public var files: [URL] = []
    public var recording: Recording?
    public var replyMessage: ReplyMessage?
}

struct InputView: View {

    @Environment(\.chatTheme) private var theme
    @Environment(\.mediaPickerTheme) private var pickerTheme

    @ObservedObject var viewModel: InputViewModel
    var inputFieldId: UUID
    var style: InputViewStyle
    var availableInput: AvailableInputType
    var messageUseMarkdown: Bool
    var inputViewTheme = InputViewTheme.default

    @StateObject var recordingPlayer = RecordingPlayer()

    private var onAction: (InputViewAction) -> Void {
        viewModel.inputViewAction()
    }

    private var state: InputViewState {
        viewModel.state
    }

    @State private var overlaySize: CGSize = .zero

    @State private var recordButtonFrame: CGRect = .zero
    @State private var lockRecordFrame: CGRect = .zero
    @State private var deleteRecordFrame: CGRect = .zero

    @State private var dragStart: Date?
    @State private var tapDelayTimer: Timer?
    @State private var cancelGesture = false
    let tapDelay = 0.2

    var body: some View {
        VStack {
            viewOnTop
            HStack(alignment: .bottom, spacing: inputViewTheme.inputAreaSpacing) {
                HStack(alignment: .bottom, spacing: 0) {
                    if viewModel.showLeftView {
                        leftView
                    }
                    middleView
                    // rightView
                    rigthOutsideButton
                }
                .background {
                    RoundedRectangle(cornerRadius: inputViewTheme.inputCornerRadius)
                        .fill(fieldBackgroundColor)
                }
            }
            .padding(.horizontal, inputViewTheme.paddingHorizontal)
            .padding(.vertical, inputViewTheme.paddingVertical)
        }
        .background(backgroundColor)
        .onAppear {
            viewModel.recordingPlayer = recordingPlayer
        }
    }

    @ViewBuilder
    var leftView: some View {
        if [.isRecordingTap, .isRecordingHold, .hasRecording, .playingRecording, .pausedRecording].contains(state) {
            deleteRecordButton
        } else {
            switch style {
            case .message:
                if availableInput == .full {
//                    attachButton
                    addAttachmentButton
                }
            case .signature:
                if viewModel.mediaPickerMode == .cameraSelection {
                    addButton
                } else {
                    Color.clear.frame(width: 12, height: 1)
                }
            }
        }
    }

    @ViewBuilder
    var middleView: some View {
        Group {
            switch state {
            case .hasRecording, .playingRecording, .pausedRecording:
                recordWaveform
            case .isRecordingHold:
                swipeToCancel
            case .isRecordingTap:
                recordingInProgress
            default:
                TextInputView(
                    text: $viewModel.attachments.text,
                    inputFieldId: inputFieldId,
                    style: style,
                    availableInput: availableInput
                )
            }
        }
        .frame(minHeight: inputViewTheme.middleView.minimumHeight)
    }

    @ViewBuilder
    var rightView: some View {
        Group {
            switch state {
            case .empty, .waitingForRecordingPermission:
                if case .message = style, availableInput == .full {
                    cameraButton
                }
            case .isRecordingHold, .isRecordingTap:
                recordDurationInProcess
            case .hasRecording:
                recordDuration
            case .playingRecording, .pausedRecording:
                recordDurationLeft
            default:
                Color.clear.frame(width: 8, height: 1)
            }
        }
        .frame(minHeight: inputViewTheme.rightView.minimumHeight)
    }

    @ViewBuilder
    var rigthOutsideButton: some View {
        ZStack {
            if [.isRecordingTap, .isRecordingHold].contains(state) {
                RecordIndicator()
                    .viewSize(inputViewTheme.rigthOutsideButton.viewSize)
                    .foregroundColor(theme.colors.sendButtonBackground)
            }
            Group {
                sendButton
            }
            .compositingGroup()
            .overlay(alignment: .top) {
                Group {
                    if state == .isRecordingTap {
                        stopRecordButton
                    } else if state == .isRecordingHold {
                        lockRecordButton
                    }
                }
                .sizeGetter($overlaySize)
                .offset(y: -inputViewTheme.rigthOutsideButton.overlayOffsetY)
            }
        }
        .viewSize(inputViewTheme.rigthOutsideButton.viewSize)
    }

    @ViewBuilder
    var viewOnTop: some View {
        if let message = viewModel.attachments.replyMessage {
            VStack(spacing: inputViewTheme.viewOnTop.horizontalSpacing) {
                Rectangle()
                    .foregroundColor(theme.colors.friendMessage)
                    .frame(height: 2)

                HStack {
                    theme.images.reply.replyToMessage
                    Capsule()
                        .foregroundColor(theme.colors.myMessage)
                        .frame(width: 2)
                    VStack(alignment: .leading) {
                        Text("Reply to \(message.user.name)")
                            .font(.caption2)
                            .foregroundColor(theme.colors.buttonBackground)
                        if !message.text.isEmpty {
                            textView(message.text)
                                .font(.caption2)
                                .lineLimit(1)
                                .foregroundColor(theme.colors.textLightContext)
                        }
                    }
                    .padding(.vertical, inputViewTheme.viewOnTop.verticalPadding)

                    Spacer()

                    if let first = message.attachments.first {
                        AsyncImageView(url: first.thumbnail)
                            .viewSize(inputViewTheme.viewOnTop.attachment.viewSize)
                            .cornerRadius(inputViewTheme.viewOnTop.attachment.cornerRadius)
                            .padding(.trailing, inputViewTheme.viewOnTop.attachment.trailingPadding)
                    }

                    if let _ = message.recording {
                        theme.images.inputView.microphone
                            .renderingMode(.template)
                            .foregroundColor(theme.colors.buttonBackground)
                    }

                    theme.images.reply.cancelReply
                        .onTapGesture {
                            viewModel.attachments.replyMessage = nil
                        }
                }
                .padding(.horizontal, inputViewTheme.viewOnTop.horizontalPadding)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    func textView(_ text: String) -> some View {
        if messageUseMarkdown,
           let attributed = try? AttributedString(markdown: text) {
            Text(attributed)
                .font(.system(size: inputViewTheme.textView.fontSize))
                .lineLimit(inputViewTheme.textView.lineLimit)
        } else {
            Text(text)
                .font(.system(size: inputViewTheme.textView.fontSize))
                .lineLimit(inputViewTheme.textView.lineLimit)
        }
    }

    var attachButton: some View {
        Button {
            onAction(.photo)
        } label: {
            theme.images.inputView.attach
                .viewSize(inputViewTheme.attachButton.viewSize)
                .padding(inputViewTheme.attachButton.padding)
        }
    }

    var addButton: some View {
        Button {
            onAction(.add)
        } label: {
            theme.images.inputView.add
                .viewSize(inputViewTheme.addButton.viewSize)
                .circleBackground(theme.colors.addButtonBackground)
                .padding(inputViewTheme.addButton.padding)
        }
    }

    var addAttachmentButton: some View {
        Menu {
            Button {
                onAction(.camera)
            } label: {
                Label("Camera", systemImage: "camera")
            }
            Button {
                onAction(.photo)
            } label: {
                Label("Photos", systemImage: "photo.stack")
            }
            Button {
                onAction(.document)
            } label: {
                Label("Files", systemImage: "folder")
            }
        } label: {
            theme.images.inputView.add
                .viewSize(inputViewTheme.addAttachmentButton.viewSize)
                .circleBackground(theme.colors.addButtonBackground)
                .padding(inputViewTheme.addAttachmentButton.padding)
        }
    }

    var cameraButton: some View {
        Button {
            onAction(.camera)
        } label: {
            theme.images.inputView.attachCamera
                .viewSize(inputViewTheme.cameraButton.viewSize)
                .padding(inputViewTheme.cameraButton.padding)
        }
    }

    var sendButton: some View {
        Button {
            onAction(.send)
        } label: {
            theme.images.inputView.arrowSend
                .viewSize(inputViewTheme.sendButton.viewSize)
                .circleBackground(theme.colors.sendButtonBackground)
        }
        .disabled(!state.canSend)
    }

    var recordButton: some View {
        theme.images.inputView.microphone
            .viewSize(inputViewTheme.recordButton.viewSize)
            .circleBackground(theme.colors.sendButtonBackground)
            .frameGetter($recordButtonFrame)
    }

    var deleteRecordButton: some View {
        Button {
            onAction(.deleteRecord)
        } label: {
            theme.images.recordAudio.deleteRecord
                .viewSize(inputViewTheme.deleteRecordButton.viewSize)
                .padding(inputViewTheme.deleteRecordButton.padding)
        }
        .frameGetter($deleteRecordFrame)
    }

    var stopRecordButton: some View {
        Button {
            onAction(.stopRecordAudio)
        } label: {
            theme.images.recordAudio.stopRecord
                .viewSize(inputViewTheme.stopRecordButton.viewSize)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.4), radius: inputViewTheme.stopRecordButton.shadowRadius)
                )
        }
    }

    var lockRecordButton: some View {
        Button {
            onAction(.recordAudioLock)
        } label: {
            VStack(spacing: inputViewTheme.lockRecordButton.spacing) {
                theme.images.recordAudio.lockRecord
                theme.images.recordAudio.sendRecord
            }
            .frame(width: inputViewTheme.lockRecordButton.viewWidth)
            .padding(.vertical, inputViewTheme.lockRecordButton.paddingVertical)
            .background(
                Capsule()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.4), radius: inputViewTheme.lockRecordButton.shadowRadius)
            )
        }
        .frameGetter($lockRecordFrame)
    }

    var swipeToCancel: some View {
        HStack {
            Spacer()
            Button {
                onAction(.deleteRecord)
            } label: {
                HStack {
                    theme.images.recordAudio.cancelRecord
                    Text("Cancel")
                        .font(.footnote)
                        .foregroundColor(theme.colors.textLightContext)
                }
            }
            Spacer()
        }
    }

    var recordingInProgress: some View {
        HStack {
            Spacer()
            Text("Recording...")
                .font(.footnote)
                .foregroundColor(theme.colors.textLightContext)
            Spacer()
        }
    }

    var recordDurationInProcess: some View {
        HStack {
            Circle()
                .foregroundColor(theme.colors.recordDot)
                .viewSize(6)
            recordDuration
        }
    }

    var recordDuration: some View {
        Text(DateFormatter.timeString(Int(viewModel.attachments.recording?.duration ?? 0)))
            .foregroundColor(theme.colors.textLightContext)
            .opacity(inputViewTheme.recordDuration.opacity)
            .font(.system(size: inputViewTheme.recordDuration.fontSize))
            .monospacedDigit()
            .padding(.trailing, inputViewTheme.recordDuration.paddingTrailing)
    }

    var recordDurationLeft: some View {
        Text(DateFormatter.timeString(Int(recordingPlayer.secondsLeft)))
            .foregroundColor(theme.colors.textLightContext)
            .opacity(0.6)
            .font(.caption2)
            .monospacedDigit()
            .padding(.trailing, 12)
    }

    var playRecordButton: some View {
        Button {
            onAction(.playRecord)
        } label: {
            theme.images.recordAudio.playRecord
        }
    }

    var pauseRecordButton: some View {
        Button {
            onAction(.pauseRecord)
        } label: {
            theme.images.recordAudio.pauseRecord
        }
    }

    @ViewBuilder
    var recordWaveform: some View {
        if let samples = viewModel.attachments.recording?.waveformSamples {
            HStack(spacing: inputViewTheme.recordWaveform.spacing) {
                Group {
                    if state == .hasRecording || state == .pausedRecording {
                        playRecordButton
                    } else if state == .playingRecording {
                        pauseRecordButton
                    }
                }
                .frame(width: 20)

                RecordWaveformPlaying(
                    samples: samples,
                    progress: recordingPlayer.progress,
                    color: theme.colors.textLightContext,
                    addExtraDots: inputViewTheme.recordWaveform.extraDots
                )
            }
            .padding(.horizontal, 8)
        }
    }

    var fieldBackgroundColor: Color {
        switch style {
        case .message:
            return theme.colors.inputLightContextBackground
        case .signature:
            return theme.colors.inputDarkContextBackground
        }
    }

    var backgroundColor: Color {
        switch style {
        case .message:
            return theme.colors.mainBackground
        case .signature:
            return pickerTheme.main.albumSelectionBackground
        }
    }

    func dragGesture() -> some Gesture {
        DragGesture(minimumDistance: 0.0, coordinateSpace: .global)
            .onChanged { value in
                if dragStart == nil {
                    dragStart = Date()
                    cancelGesture = false
                    tapDelayTimer = Timer.scheduledTimer(withTimeInterval: tapDelay, repeats: false) { _ in
                        if state != .isRecordingTap, state != .waitingForRecordingPermission {
                            self.onAction(.recordAudioHold)
                        }
                    }
                }

                if value.location.y < lockRecordFrame.minY,
                   value.location.x > recordButtonFrame.minX {
                    cancelGesture = true
                    onAction(.recordAudioLock)
                }

                if value.location.x < UIScreen.main.bounds.width/2,
                   value.location.y > recordButtonFrame.minY {
                    cancelGesture = true
                    onAction(.deleteRecord)
                }
            }
            .onEnded() { value in
                if !cancelGesture {
                    tapDelayTimer = nil
                    if recordButtonFrame.contains(value.location) {
                        if let dragStart = dragStart, Date().timeIntervalSince(dragStart) < tapDelay {
                            onAction(.recordAudioTap)
                        } else if state != .waitingForRecordingPermission {
                            onAction(.send)
                        }
                    }
                    else if lockRecordFrame.contains(value.location) {
                        onAction(.recordAudioLock)
                    }
                    else if deleteRecordFrame.contains(value.location) {
                        onAction(.deleteRecord)
                    } else {
                        onAction(.send)
                    }
                }
                dragStart = nil
            }
    }
}
