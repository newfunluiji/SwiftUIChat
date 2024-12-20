//
//  ChatTheme.swift
//  
//
//  Created by Alisa Mylnikova on 31.01.2023.
//

import SwiftUI

struct ChatThemeKey: EnvironmentKey {
    static var defaultValue: ChatTheme = ChatTheme()
}

extension EnvironmentValues {
    var chatTheme: ChatTheme {
        get { self[ChatThemeKey.self] }
        set { self[ChatThemeKey.self] = newValue }
    }
}

public extension View {
    func chatTheme(_ theme: ChatTheme) -> some View {
        self.environment(\.chatTheme, theme)
    }

    func chatTheme(colors: ChatTheme.Colors = .init(),
                   images: ChatTheme.Images = .init()) -> some View {
        self.environment(\.chatTheme, ChatTheme(colors: colors, images: images))
    }
}

public struct ChatTheme {
    public let colors: ChatTheme.Colors
    public let images: ChatTheme.Images
    public let messageViewTheme: MessageViewTheme
    

    public init(colors: ChatTheme.Colors = .init(),
                images: ChatTheme.Images = .init(),
                messageViewTheme: MessageViewTheme = .default) {
        self.colors = colors
        self.images = images
        self.messageViewTheme = messageViewTheme
    }

    public struct Colors {
        public var grayStatus: Color
        public var errorStatus: Color

        public var inputLightContextBackground: Color
        public var inputDarkContextBackground: Color

        public var mainBackground: Color
        public var buttonBackground: Color
        public var addButtonBackground: Color
        public var sendButtonBackground: Color

        public var myMessage: Color
        public var friendMessage: Color
        public var suggestionMessage: Color


        public var textLightContext: Color
        public var textDarkContext: Color
        public var textMediaPicker: Color

        public var recordDot: Color

        public var myMessageTime: Color
        public var frientMessageTime: Color

        public var timeCapsuleBackground: Color
        public var timeCapsuleForeground: Color

        public init(
            grayStatus: Color = Color(hex: "AFB3B8"),
            errorStatus: Color = Color.red,
            inputLightContextBackground: Color = Color(hex: "F2F3F5"),
            inputDarkContextBackground: Color = Color(hex: "F2F3F5").opacity(0.12),
            mainBackground: Color = .white,
            buttonBackground: Color = Color(hex: "989EAC"),
            addButtonBackground: Color = Color(hex: "#4F5055"),
            sendButtonBackground: Color = Color(hex: "#4962FF"),
            myMessage: Color = Color(hex: "4962FF"),
            friendMessage: Color = Color(hex: "EBEDF0"),
            suggestionMessage: Color = Color(hex: "EBEDF0"),
            textLightContext: Color = Color.black,
            textDarkContext: Color = Color.white,
            textMediaPicker: Color = Color(hex: "818C99"),
            recordDot: Color = Color(hex: "F62121"),
            myMessageTime: Color = .white.opacity(0.4),
            frientMessageTime: Color = .black.opacity(0.4),
            timeCapsuleBackground: Color = .black.opacity(0.4),
            timeCapsuleForeground: Color = .white
        ) {
            self.grayStatus = grayStatus
            self.errorStatus = errorStatus
            self.inputLightContextBackground = inputLightContextBackground
            self.inputDarkContextBackground = inputDarkContextBackground
            self.mainBackground = mainBackground
            self.buttonBackground = buttonBackground
            self.addButtonBackground = addButtonBackground
            self.sendButtonBackground = sendButtonBackground
            self.myMessage = myMessage
            self.friendMessage = friendMessage
            self.suggestionMessage = suggestionMessage
            self.textLightContext = textLightContext
            self.textDarkContext = textDarkContext
            self.textMediaPicker = textMediaPicker
            self.recordDot = recordDot
            self.myMessageTime = myMessageTime
            self.frientMessageTime = frientMessageTime
            self.timeCapsuleBackground = timeCapsuleBackground
            self.timeCapsuleForeground = timeCapsuleForeground
        }
    }

    public struct Images {

        public struct AttachMenu {
            public var camera: Image
            public var contact: Image
            public var document: Image
            public var location: Image
            public var photo: Image
            public var pickDocument: Image
            public var pickLocation: Image
            public var pickPhoto: Image
        }

        public struct InputView {
            public var add: Image
            public var arrowSend: Image
            public var attach: Image
            public var attachCamera: Image
            public var microphone: Image
        }

        public struct FullscreenMedia {
            public var play: Image
            public var pause: Image
            public var mute: Image
            public var unmute: Image
        }

        public struct MediaPicker {
            public var chevronDown: Image
            public var chevronRight: Image
            public var cross: Image
        }

        public struct Message {
            public var attachedDocument: Image
            public var checkmarks: Image
            public var error: Image
            public var muteVideo: Image
            public var pauseAudio: Image
            public var pauseVideo: Image
            public var playAudio: Image
            public var playVideo: Image
            public var sending: Image
        }

        public struct MessageMenu {
            public var delete: Image
            public var edit: Image
            public var forward: Image
            public var reply: Image
            public var retry: Image
            public var save: Image
            public var select: Image
        }

        public struct RecordAudio {
            public var cancelRecord: Image
            public var deleteRecord: Image
            public var lockRecord: Image
            public var pauseRecord: Image
            public var playRecord: Image
            public var sendRecord: Image
            public var stopRecord: Image
        }

        public struct Reply {
            public var cancelReply: Image
            public var replyToMessage: Image
        }

        public var backButton: Image
        public var scrollToBottom: Image

        public var attachMenu: AttachMenu
        public var inputView: InputView
        public var fullscreenMedia: FullscreenMedia
        public var mediaPicker: MediaPicker
        public var message: Message
        public var messageMenu: MessageMenu
        public var recordAudio: RecordAudio
        public var reply: Reply

        public init(
            bundle: Bundle = .current,
            camera: Image? = nil,
            contact: Image? = nil,
            document: Image? = nil,
            location: Image? = nil,
            photo: Image? = nil,
            pickDocument: Image? = nil,
            pickLocation: Image? = nil,
            pickPhoto: Image? = nil,
            add: Image? = nil,
            arrowSend: Image? = nil,
            attach: Image? = nil,
            attachCamera: Image? = nil,
            microphone: Image? = nil,
            fullscreenPlay: Image? = nil,
            fullscreenPause: Image? = nil,
            fullscreenMute: Image? = nil,
            fullscreenUnmute: Image? = nil,
            chevronDown: Image? = nil,
            chevronRight: Image? = nil,
            cross: Image? = nil,
            attachedDocument: Image? = nil,
            checkmarks: Image? = nil,
            error: Image? = nil,
            muteVideo: Image? = nil,
            pauseAudio: Image? = nil,
            pauseVideo: Image? = nil,
            playAudio: Image? = nil,
            playVideo: Image? = nil,
            sending: Image? = nil,
            delete: Image? = nil,
            edit: Image? = nil,
            forward: Image? = nil,
            reply: Image? = nil,
            retry: Image? = nil,
            save: Image? = nil,
            select: Image? = nil,
            cancelRecord: Image? = nil,
            deleteRecord: Image? = nil,
            lockRecord: Image? = nil,
            pauseRecord: Image? = nil,
            playRecord: Image? = nil,
            sendRecord: Image? = nil,
            stopRecord: Image? = nil,
            cancelReply: Image? = nil,
            replyToMessage: Image? = nil,
            backButton: Image? = nil,
            scrollToBottom: Image? = nil
        ) {
            self.backButton = backButton ?? Image("backArrow", bundle: bundle)
            self.scrollToBottom = scrollToBottom ?? Image("scrollToBottom", bundle: bundle)

            self.attachMenu = AttachMenu(
                camera: camera ?? Image("camera", bundle: bundle),
                contact: contact ?? Image("contact", bundle: bundle),
                document: document ?? Image("document", bundle: bundle),
                location: location ?? Image("location", bundle: bundle),
                photo: photo ?? Image("photo", bundle: bundle),
                pickDocument: pickDocument ?? Image("pickDocument", bundle: bundle),
                pickLocation: pickLocation ?? Image("pickLocation", bundle: bundle),
                pickPhoto: pickPhoto ?? Image("pickPhoto", bundle: bundle)
            )

            self.inputView = InputView(
                add: add ?? Image("add", bundle: bundle),
                arrowSend: arrowSend ?? Image("arrowSend", bundle: bundle),
                attach: attach ?? Image("attach", bundle: bundle),
                attachCamera: attachCamera ?? Image("attachCamera", bundle: bundle),
                microphone: microphone ?? Image("microphone", bundle: bundle)
            )

            self.fullscreenMedia = FullscreenMedia(
                play: fullscreenPlay ?? Image(systemName: "play.fill"),
                pause: fullscreenPause ?? Image(systemName: "pause.fill"),
                mute: fullscreenMute ?? Image(systemName: "speaker.slash.fill"),
                unmute: fullscreenUnmute ?? Image(systemName: "speaker.fill")
            )

            self.mediaPicker = MediaPicker(
                chevronDown: chevronDown ?? Image("chevronDown", bundle: bundle),
                chevronRight: chevronRight ?? Image("chevronRight", bundle: bundle),
                cross: cross ?? Image("cross", bundle: bundle)
            )

            self.message = Message(
                attachedDocument: attachedDocument ?? Image("attachedDocument", bundle: bundle),
                checkmarks: checkmarks ?? Image("checkmarks", bundle: bundle),
                error: error ?? Image("error", bundle: bundle),
                muteVideo: muteVideo ?? Image("muteVideo", bundle: bundle),
                pauseAudio: pauseAudio ?? Image("pauseAudio", bundle: bundle),
                pauseVideo: pauseVideo ?? Image(systemName: "pause.circle.fill"),
                playAudio: playAudio ?? Image("playAudio", bundle: bundle),
                playVideo: playVideo ?? Image(systemName: "play.circle.fill"),
                sending: sending ?? Image("sending", bundle: bundle)
            )

            self.messageMenu = MessageMenu(
                delete: delete ?? Image("delete", bundle: bundle),
                edit: edit ?? Image("edit", bundle: bundle),
                forward: forward ?? Image("forward", bundle: bundle),
                reply: reply ?? Image("reply", bundle: bundle),
                retry: retry ?? Image("retry", bundle: bundle),
                save: save ?? Image("save", bundle: bundle),
                select: select ?? Image("select", bundle: bundle)
            )

            self.recordAudio = RecordAudio(
                cancelRecord: cancelRecord ?? Image("cancelRecord", bundle: bundle),
                deleteRecord: deleteRecord ?? Image("deleteRecord", bundle: bundle),
                lockRecord: lockRecord ?? Image("lockRecord", bundle: bundle),
                pauseRecord: pauseRecord ?? Image("pauseRecord", bundle: bundle),
                playRecord: playRecord ?? Image("playRecord", bundle: bundle),
                sendRecord: sendRecord ?? Image("sendRecord", bundle: bundle),
                stopRecord: stopRecord ?? Image("stopRecord", bundle: bundle)
            )

            self.reply = Reply(
                cancelReply: cancelReply ?? Image("cancelReply", bundle: bundle),
                replyToMessage: replyToMessage ?? Image("replyToMessage", bundle: bundle)
            )
        }
    }
}

public struct InputViewTheme {
    public let viewOnTop = ViewOnTop()
    public let middleView = MiddleViewTheme()
    public let rightView: RightViewTheme = RightViewTheme()
    public let rigthOutsideButton = RightOutsideButtonTheme()
    public let textView = TextViewTheme()
    public let attachButton = AttachButtonTheme()
    public let addButton = AddButtonTheme()
    public let addAttachmentButton = AddAttachmentButtonTheme()
    public let cameraButton = CameraButtonTheme()
    public let sendButton = SendButtonTheme()
    public let recordButton = RecordButtonTheme()
    public let deleteRecordButton = DeleteRecordButtonTheme()
    public let stopRecordButton = StopRecordButtonTheme()
    public let lockRecordButton = LockRecordButtonTheme()
    public let recordWaveform = RecordWaveformTheme()
    public let recordDuration = RecordDurationTheme()
    public let paddingHorizontal: CGFloat
    public let paddingVertical: CGFloat
    public let inputAreaSpacing: CGFloat
    public let inputCornerRadius: CGFloat

    public init(
        paddingHorizontal: CGFloat = 20,
        paddingVertical: CGFloat = 20,
        inputAreaSpacing: CGFloat = 8,
        inputCornerRadius: CGFloat = 32
    ) {
        self.paddingHorizontal = paddingHorizontal
        self.paddingVertical = paddingVertical
        self.inputAreaSpacing = inputAreaSpacing
        self.inputCornerRadius = inputCornerRadius
    }
    // MARK: - Camera Button Theme
    public struct CameraButtonTheme {
       public let viewSize: CGFloat
       public let padding: EdgeInsets

       public init(viewSize: CGFloat = 24, padding: EdgeInsets = .init(top: 12, leading: 8, bottom: 12, trailing: 12)) {
           self.viewSize = viewSize
           self.padding = padding
       }
    }

    // MARK: - Send Button Theme
    public struct SendButtonTheme {
       public let viewSize: CGFloat

       public init(viewSize: CGFloat = 48) {
           self.viewSize = viewSize
       }
    }

    // MARK: - Record Button Theme
    public struct RecordButtonTheme {
       public let viewSize: CGFloat

       public init(viewSize: CGFloat = 48) {
           self.viewSize = viewSize
       }
    }

    // MARK: - Delete Record Button Theme
    public struct DeleteRecordButtonTheme {
       public let viewSize: CGFloat
       public let padding: EdgeInsets

       public init(viewSize: CGFloat = 24, padding: EdgeInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 8)) {
           self.viewSize = viewSize
           self.padding = padding
       }
    }

    // MARK: - Stop Record Button Theme
    public struct StopRecordButtonTheme {
       public let viewSize: CGFloat
       public let shadowRadius: CGFloat

       public init(viewSize: CGFloat = 28, shadowRadius: CGFloat = 1) {
           self.viewSize = viewSize
           self.shadowRadius = shadowRadius
       }
    }

    // MARK: - Lock Record Button Theme
    public struct LockRecordButtonTheme {
       public let viewWidth: CGFloat
       public let paddingVertical: CGFloat
       public let spacing: CGFloat
       public let shadowRadius: CGFloat

       public init(viewWidth: CGFloat = 28, paddingVertical: CGFloat = 16, spacing: CGFloat = 20, shadowRadius: CGFloat = 1) {
           self.viewWidth = viewWidth
           self.paddingVertical = paddingVertical
           self.spacing = spacing
           self.shadowRadius = shadowRadius
       }
    }

    // MARK: - Record Waveform Theme
    public struct RecordWaveformTheme {
       public let spacing: CGFloat
       public let extraDots: Bool

       public init(spacing: CGFloat = 8, extraDots: Bool = true) {
           self.spacing = spacing
           self.extraDots = extraDots
       }
    }

    // MARK: - Record Duration Theme
    public struct RecordDurationTheme {
       public let fontSize: CGFloat
       public let opacity: Double
       public let paddingTrailing: CGFloat

       public init(fontSize: CGFloat = 10, opacity: Double = 0.6, paddingTrailing: CGFloat = 12) {
           self.fontSize = fontSize
           self.opacity = opacity
           self.paddingTrailing = paddingTrailing
       }
    }

    public struct TextViewTheme {
        public let fontSize: CGFloat
        public let lineLimit: Int

        public init(fontSize: CGFloat = 12, lineLimit: Int = 1) {
            self.fontSize = fontSize
            self.lineLimit = lineLimit
        }
    }

    public struct AttachButtonTheme {
        public let viewSize: CGFloat
        public let padding: EdgeInsets

        public init(
            viewSize: CGFloat = 24,
            padding: EdgeInsets = EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 8)
        ) {
            self.viewSize = viewSize
            self.padding = padding
        }
    }

    public struct AddButtonTheme {
        public let viewSize: CGFloat
        public let padding: EdgeInsets

        public init(
            viewSize: CGFloat = 24,
            padding: EdgeInsets = EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 8)
        ) {
            self.viewSize = viewSize
            self.padding = padding
        }
    }

    public struct AddAttachmentButtonTheme {
        public let viewSize: CGFloat
        public let padding: EdgeInsets

        public init(
            viewSize: CGFloat = 24,
            padding: EdgeInsets = EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 8)
        ) {
            self.viewSize = viewSize
            self.padding = padding
        }
    }
    public struct ViewOnTop {
        public let horizontalSpacing: CGFloat
        public let verticalPadding: CGFloat
        public let horizontalPadding: CGFloat
        public let attachment: Attachment
        
        public init(
            horizontalSpacing: CGFloat = 8,
            verticalPadding: CGFloat = 8,
            horizontalPadding: CGFloat = 26,
            attachment: Attachment = Attachment()
        ) {
            self.horizontalSpacing = horizontalSpacing
            self.verticalPadding = verticalPadding
            self.horizontalPadding = horizontalPadding
            self.attachment = attachment
        }
        
        public struct Attachment {
            public let viewSize: CGFloat
            public let cornerRadius: CGFloat
            public let trailingPadding: CGFloat
            
            public init(
                viewSize: CGFloat = 30,
                cornerRadius: CGFloat = 4,
                trailingPadding: CGFloat = 16
            ) {
                self.viewSize = viewSize
                self.cornerRadius = cornerRadius
                self.trailingPadding = trailingPadding
            }
        }
    }
    public struct MiddleViewTheme {
        public let minimumHeight: CGFloat

        public init(minimumHeight: CGFloat = 48) {
            self.minimumHeight = minimumHeight
        }
    }
    public struct RightViewTheme {
        public let minimumHeight: CGFloat

        public init(minimumHeight: CGFloat = 48) {
            self.minimumHeight = minimumHeight
        }
    }

    public struct RightOutsideButtonTheme {
        public let viewSize: CGFloat
        public let overlayOffsetY: CGFloat

        public init(
            viewSize: CGFloat = 48,
            overlayOffsetY: CGFloat = 24
        ) {
            self.viewSize = viewSize
            self.overlayOffsetY = overlayOffsetY
        }
    }

}

extension InputViewTheme {
    static var `default`: InputViewTheme { .init() }
}

public struct SuggestionViewTheme {
    public let bubble = BubbleTheme()
    public let messagePadding: EdgeInsets
    public let bubbleCornerRadius: CGFloat
    public let bubbleSpacing: CGFloat
    public let horizontalPadding: CGFloat
    public let verticalPadding: CGFloat
    public let fontSize: CGFloat

    public init(
        messagePadding: EdgeInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4),
        bubbleCornerRadius: CGFloat = 10,
        bubbleSpacing: CGFloat = 4,
        horizontalPadding: CGFloat = 4,
        verticalPadding: CGFloat = 2,
        fontSize: CGFloat = 15
    ) {
        self.messagePadding = messagePadding
        self.bubbleCornerRadius = bubbleCornerRadius
        self.bubbleSpacing = bubbleSpacing
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.fontSize = fontSize
    }

    // MARK: - Bubble Theme
    public struct BubbleTheme {
        public let backgroundOpacity: Double
        public let borderWidth: CGFloat
        public let borderColor: Color

        public init(
            backgroundOpacity: Double = 1.0,
            borderWidth: CGFloat = 1,
            borderColor: Color = .gray
        ) {
            self.backgroundOpacity = backgroundOpacity
            self.borderWidth = borderWidth
            self.borderColor = borderColor
        }
    }
}
extension SuggestionViewTheme {
    public static var `default`: SuggestionViewTheme { .init() }
}

public struct MessageViewTheme {
    public let avatar: AvatarTheme
    public let bubble: BubbleTheme
    public let textWithTime: TextWithTimeTheme
    public let recording: RecordingTheme
    public let attachments: AttachmentsTheme
    public let replyBubble: ReplyBubbleTheme
    public let status: StatusTheme
    public let widthWithMedia: CGFloat
    public let horizontalAvatarPadding: CGFloat
    public let horizontalTextPadding: CGFloat
    public let horizontalAttachmentPadding: CGFloat
    public let statusViewSize: CGFloat
    public let horizontalStatusPadding: CGFloat
    public let horizontalBubblePadding: CGFloat
    public init(
        avatar: AvatarTheme = .init(),
        bubble: BubbleTheme = .init(),
        textWithTime: TextWithTimeTheme = .init(),
        recording: RecordingTheme = .init(),
        attachments: AttachmentsTheme = .init(),
        replyBubble: ReplyBubbleTheme = .init(),
        status: StatusTheme = .init(),
        widthWithMedia: CGFloat = 204,
        horizontalAvatarPadding: CGFloat = 8,
        horizontalTextPadding: CGFloat = 16,
        horizontalAttachmentPadding: CGFloat = 1,
        statusViewSize: CGFloat = 14,
        horizontalStatusPadding: CGFloat = 8,
        horizontalBubblePadding: CGFloat = 70
    ) {
        self.avatar = avatar
        self.bubble = bubble
        self.textWithTime = textWithTime
        self.recording = recording
        self.attachments = attachments
        self.replyBubble = replyBubble
        self.status = status
        self.widthWithMedia = widthWithMedia
        self.horizontalAvatarPadding = horizontalAvatarPadding
        self.horizontalTextPadding = horizontalTextPadding
        self.horizontalAttachmentPadding = horizontalAttachmentPadding
        self.statusViewSize = statusViewSize
        self.horizontalStatusPadding = horizontalStatusPadding
        self.horizontalBubblePadding = horizontalBubblePadding
        
    }

    // MARK: - Avatar Theme
    public struct AvatarTheme {
        public let size: CGFloat
        public let horizontalPadding: CGFloat

        public init(size: CGFloat = 40, horizontalPadding: CGFloat = 8) {
            self.size = size
            self.horizontalPadding = horizontalPadding
        }
    }

    // MARK: - Bubble Theme
    public struct BubbleTheme {
        public let cornerRadius: CGFloat
        public let paddingTop: CGFloat
        public let paddingBottom: CGFloat

        public init(
            cornerRadius: CGFloat = 20,
            paddingTop: CGFloat = 8,
            paddingBottom: CGFloat = 4
        ) {
            self.cornerRadius = cornerRadius
            self.paddingTop = paddingTop
            self.paddingBottom = paddingBottom
        }
    }

    // MARK: - Text with Time Theme
    public struct TextWithTimeTheme {
        public let font: Font
        public let timeFont: Font
        public let spacing: CGFloat
        public let horizontalPadding: CGFloat
        public let verticalPadding: CGFloat

        public init(
            font: Font = .body,
            timeFont: Font = .caption2,
            spacing: CGFloat = 12,
            horizontalPadding: CGFloat = 12,
            verticalPadding: CGFloat = 8
        ) {
            self.font = font
            self.timeFont = timeFont
            self.spacing = spacing
            self.horizontalPadding = horizontalPadding
            self.verticalPadding = verticalPadding
        }
    }

    // MARK: - Recording Theme
    public struct RecordingTheme {
        public let padding: EdgeInsets

        public init(
            padding: EdgeInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 12)
        ) {
            self.padding = padding
        }
    }

    // MARK: - Attachments Theme
    public struct AttachmentsTheme {
        public let gridSpacing: CGFloat
        public let padding: EdgeInsets

        public init(
            gridSpacing: CGFloat = 4,
            padding: EdgeInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        ) {
            self.gridSpacing = gridSpacing
            self.padding = padding
        }
    }

    // MARK: - Reply Bubble Theme
    public struct ReplyBubbleTheme {
        public let font: Font
        public let nameFont: Font
        public let padding: EdgeInsets

        public init(
            font: Font = .caption,
            nameFont: Font = .caption2.weight(.semibold),
            padding: EdgeInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 12)
        ) {
            self.font = font
            self.nameFont = nameFont
            self.padding = padding
        }
    }

    // MARK: - Status Theme
    public struct StatusTheme {
        public let size: CGFloat

        public init(
            size: CGFloat = 14
        ) {
            self.size = size
        }
    }
}

extension MessageViewTheme {
    public static var `default`: MessageViewTheme { .init() }
}
