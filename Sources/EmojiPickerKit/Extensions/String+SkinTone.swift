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
    func normalizingSkinTone(to mode: EmojiSkinToneNormalization) -> String {
        guard !isEmpty else { return self }

        let skinToneRange: ClosedRange<UInt32> = 0x1F3FB...0x1F3FF

        // Step 1: Strip existing skin tone modifiers
        var stripped = String.UnicodeScalarView()
        for scalar in unicodeScalars {
            if skinToneRange.contains(scalar.value) {
                continue
            }
            stripped.append(scalar)
        }

        // Step 2: If .strip, return base
        guard let toneScalar = mode.scalar else {
            return String(stripped)
        }

        // Step 3: Insert new modifier after each Emoji_Modifier_Base
        let hasModifierBase = stripped.contains { $0.properties.isEmojiModifierBase }
        guard hasModifierBase else { return String(stripped) }

        var result = String.UnicodeScalarView()
        for scalar in stripped {
            result.append(scalar)
            if scalar.properties.isEmojiModifierBase {
                result.append(toneScalar)
            }
        }

        return String(result)
    }
}
