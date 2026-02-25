import UIKit

public struct EmojiKeyboardConfiguration {
    public var emojiOnly: Bool = true
    public var normalizeSkinTone: EmojiSkinToneNormalization? = nil
    public var hapticFeedback: UIImpactFeedbackGenerator.FeedbackStyle? = .light
    public var disableDictation: Bool = false

    public init(
        emojiOnly: Bool = true,
        normalizeSkinTone: EmojiSkinToneNormalization? = nil,
        hapticFeedback: UIImpactFeedbackGenerator.FeedbackStyle? = .light,
        disableDictation: Bool = false
    ) {
        self.emojiOnly = emojiOnly
        self.normalizeSkinTone = normalizeSkinTone
        self.hapticFeedback = hapticFeedback
        self.disableDictation = disableDictation
    }

    public static let `default` = EmojiKeyboardConfiguration()
}
