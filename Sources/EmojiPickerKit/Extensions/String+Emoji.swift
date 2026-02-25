import Foundation

extension String {
    /// Returns `true` if every unicode scalar in this string is part of an emoji rendering.
    /// An empty string returns `false`.
    var isEmoji: Bool {
        guard !isEmpty else { return false }

        // Check each Character (grapheme cluster) individually
        return allSatisfy { character in
            let scalars = Array(character.unicodeScalars)
            guard !scalars.isEmpty else { return false }

            // 1. Keycap sequences: base (0-9, #, *) + VS-16(U+FE0F) + U+20E3
            let keycapBases: Set<UInt32> = Set(0x30...0x39).union([0x23, 0x2A])
            if scalars.count >= 2,
               keycapBases.contains(scalars[0].value),
               scalars.contains(where: { $0.value == 0x20E3 }) {
                return true
            }

            // 2. Check if VS-16 is present in this character's scalars
            let containsVS16 = scalars.contains { $0.value == 0xFE0F }

            // 3. Must have at least one "base" emoji scalar (not just modifiers/markers)
            let hasEmojiBase = scalars.contains { scalar in
                scalar.properties.isEmojiPresentation
                    || scalar.properties.isEmojiModifierBase
                    || (scalar.value >= 0x1F1E6 && scalar.value <= 0x1F1FF)
                    || (scalar.properties.isEmoji && containsVS16 && scalar.value != 0xFE0F)
            }
            guard hasEmojiBase else { return false }

            // 4. Verify all scalars are emoji-related
            return scalars.allSatisfy { scalar in
                scalar.properties.isEmojiPresentation        // default emoji presentation
                    || scalar.properties.isEmojiModifierBase // skin tone base (👋)
                    || scalar.properties.isEmojiModifier     // skin tone modifier (🏽)
                    || scalar.value == 0xFE0F               // variation selector-16
                    || scalar.value == 0x200D               // ZWJ
                    || (scalar.value >= 0x1F1E6 && scalar.value <= 0x1F1FF) // regional indicator (flags)
                    || scalar.value == 0x20E3               // combining enclosing keycap
                    || (scalar.properties.isEmoji && containsVS16) // text-default + VS-16
            }
        }
    }

    /// Returns `true` if this string renders as exactly one emoji glyph.
    /// Swift's `Character` treats ZWJ sequences as a single grapheme cluster,
    /// so `count == 1` is sufficient.
    var isSingleEmoji: Bool {
        count == 1 && isEmoji
    }
}
