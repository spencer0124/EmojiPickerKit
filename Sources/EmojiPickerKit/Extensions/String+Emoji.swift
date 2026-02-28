import Foundation

private enum UnicodeConstants {
    static let variationSelector16: UInt32 = 0xFE0F
    static let zeroWidthJoiner: UInt32 = 0x200D
    static let combiningEnclosingKeycap: UInt32 = 0x20E3
    static let regionalIndicatorStart: UInt32 = 0x1F1E6
    static let regionalIndicatorEnd: UInt32 = 0x1F1FF
}

extension String {
    /// Returns `true` if every character in this string is an emoji.
    /// An empty string returns `false`.
    public var containsOnlyEmoji: Bool {
        guard !isEmpty else { return false }

        // Check each Character (grapheme cluster) individually
        return allSatisfy { character in
            let scalars = Array(character.unicodeScalars)
            guard !scalars.isEmpty else { return false }

            // 1. Keycap sequences: base (0-9, #, *) + VS-16 + combining enclosing keycap
            let keycapBases: Set<UInt32> = Set(0x30...0x39).union([0x23, 0x2A])
            if scalars.count >= 2,
               keycapBases.contains(scalars[0].value),
               scalars.contains(where: { $0.value == UnicodeConstants.combiningEnclosingKeycap }) {
                return true
            }

            // 2. Check if VS-16 is present in this character's scalars
            let containsVS16 = scalars.contains { $0.value == UnicodeConstants.variationSelector16 }

            // 3. Must have at least one "base" emoji scalar (not just modifiers/markers)
            let hasEmojiBase = scalars.contains { scalar in
                scalar.properties.isEmojiPresentation
                    || scalar.properties.isEmojiModifierBase
                    || (scalar.value >= UnicodeConstants.regionalIndicatorStart && scalar.value <= UnicodeConstants.regionalIndicatorEnd)
                    || (scalar.properties.isEmoji && containsVS16 && scalar.value != UnicodeConstants.variationSelector16)
            }
            guard hasEmojiBase else { return false }

            // 4. Verify all scalars are emoji-related
            return scalars.allSatisfy { scalar in
                scalar.properties.isEmojiPresentation
                    || scalar.properties.isEmojiModifierBase
                    || scalar.properties.isEmojiModifier
                    || scalar.value == UnicodeConstants.variationSelector16
                    || scalar.value == UnicodeConstants.zeroWidthJoiner
                    || (scalar.value >= UnicodeConstants.regionalIndicatorStart && scalar.value <= UnicodeConstants.regionalIndicatorEnd)
                    || scalar.value == UnicodeConstants.combiningEnclosingKeycap
                    || (scalar.properties.isEmoji && containsVS16)
            }
        }
    }

    /// Returns `true` if this string renders as exactly one emoji glyph.
    /// Swift's `Character` treats ZWJ sequences as a single grapheme cluster,
    /// so `count == 1` is sufficient.
    public var isSingleEmoji: Bool {
        count == 1 && containsOnlyEmoji
    }

    /// Returns an array of emoji characters found in this string.
    public var emojis: [Character] {
        filter { String($0).containsOnlyEmoji }
    }

    /// Returns the number of emoji glyphs in this string.
    public var emojiCount: Int {
        emojis.count
    }

    /// Returns a new string with all emoji characters removed.
    public var removingEmojis: String {
        String(filter { !String($0).containsOnlyEmoji })
    }

    /// Returns a new string with all emoji removed, consecutive whitespace collapsed, and leading/trailing whitespace trimmed.
    public var strippingEmojis: String {
        removingEmojis
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
    }

    /// Splits a ZWJ emoji sequence into its component emoji.
    /// Non-ZWJ emoji return a single-element array. Non-emoji strings return an empty array.
    public var emojiComponents: [String] {
        guard isSingleEmoji else { return [] }
        var components: [String] = []
        var current = String.UnicodeScalarView()
        for scalar in unicodeScalars {
            if scalar.value == UnicodeConstants.zeroWidthJoiner {
                if !current.isEmpty {
                    components.append(String(current))
                    current = String.UnicodeScalarView()
                }
            } else {
                current.append(scalar)
            }
        }
        if !current.isEmpty {
            components.append(String(current))
        }
        return components
    }
}
