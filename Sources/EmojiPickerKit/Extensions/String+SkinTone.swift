import Foundation

/// Skin tone normalization modes for emoji.
public enum EmojiSkinToneNormalization {
    case strip
    case light
    case mediumLight
    case medium
    case mediumDark
    case dark

    /// The Unicode scalar for this skin tone modifier, or `nil` for `.strip`.
    public var scalar: Unicode.Scalar? {
        switch self {
        case .strip:       return nil
        case .light:       return Unicode.Scalar(0x1F3FB)
        case .mediumLight: return Unicode.Scalar(0x1F3FC)
        case .medium:      return Unicode.Scalar(0x1F3FD)
        case .mediumDark:  return Unicode.Scalar(0x1F3FE)
        case .dark:        return Unicode.Scalar(0x1F3FF)
        }
    }
}

extension String {
    /// Returns a new string with skin tone modifiers normalized.
    ///
    /// - `.strip`: removes existing skin tone modifiers (U+1F3FB-U+1F3FF).
    /// - Specific tone: removes existing modifiers, then appends the new modifier
    ///   after each `Emoji_Modifier_Base` scalar.
    /// - ZWJ sequences are handled correctly — the modifier is applied after each
    ///   `Emoji_Modifier_Base` scalar while preserving ZWJ and non-base components.
    public func normalizingSkinTone(to mode: EmojiSkinToneNormalization) -> String {
        guard !isEmpty else { return self }

        let skinToneRange: ClosedRange<UInt32> = 0x1F3FB...0x1F3FF
        let toneScalar = mode.scalar

        var result = String.UnicodeScalarView()
        for scalar in unicodeScalars {
            if skinToneRange.contains(scalar.value) { continue }
            result.append(scalar)
            if let tone = toneScalar, scalar.properties.isEmojiModifierBase {
                result.append(tone)
            }
        }

        return String(result)
    }

    /// Returns the skin tone of this emoji, or `nil` if no skin tone modifier is present.
    public var emojiSkinTone: EmojiSkinToneNormalization? {
        let skinTones: [(ClosedRange<UInt32>, EmojiSkinToneNormalization)] = [
            (0x1F3FB...0x1F3FB, .light),
            (0x1F3FC...0x1F3FC, .mediumLight),
            (0x1F3FD...0x1F3FD, .medium),
            (0x1F3FE...0x1F3FE, .mediumDark),
            (0x1F3FF...0x1F3FF, .dark),
        ]
        for scalar in unicodeScalars {
            for (range, tone) in skinTones {
                if range.contains(scalar.value) { return tone }
            }
        }
        return nil
    }
}
