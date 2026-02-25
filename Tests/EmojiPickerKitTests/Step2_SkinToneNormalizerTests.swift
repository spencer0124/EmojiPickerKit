import XCTest
@testable import EmojiPickerKit

final class Step2_SkinToneNormalizerTests: XCTestCase {

    // MARK: - scalar property

    func test_scalar_stripIsNil() {
        XCTAssertNil(EmojiSkinToneNormalization.strip.scalar)
    }

    func test_scalar_toneValues() {
        XCTAssertEqual(EmojiSkinToneNormalization.light.scalar, Unicode.Scalar(0x1F3FB))
        XCTAssertEqual(EmojiSkinToneNormalization.mediumLight.scalar, Unicode.Scalar(0x1F3FC))
        XCTAssertEqual(EmojiSkinToneNormalization.medium.scalar, Unicode.Scalar(0x1F3FD))
        XCTAssertEqual(EmojiSkinToneNormalization.mediumDark.scalar, Unicode.Scalar(0x1F3FE))
        XCTAssertEqual(EmojiSkinToneNormalization.dark.scalar, Unicode.Scalar(0x1F3FF))
    }

    // MARK: - .strip

    func test_strip_removesMediumTone() {
        XCTAssertEqual("👋🏽".normalizingSkinTone(to: .strip), "👋")
    }

    func test_strip_removesLightTone() {
        XCTAssertEqual("👋🏻".normalizingSkinTone(to: .strip), "👋")
    }

    func test_strip_removesDarkTone() {
        XCTAssertEqual("👋🏿".normalizingSkinTone(to: .strip), "👋")
    }

    func test_strip_nonModifierBaseUnchanged() {
        XCTAssertEqual("😊".normalizingSkinTone(to: .strip), "😊")
    }

    func test_strip_alreadyDefaultUnchanged() {
        XCTAssertEqual("👋".normalizingSkinTone(to: .strip), "👋")
    }

    // MARK: - tone replacement

    func test_replaceTone_mediumToDark() {
        XCTAssertEqual("👋🏽".normalizingSkinTone(to: .dark), "👋🏿")
    }

    func test_replaceTone_mediumToLight() {
        XCTAssertEqual("👋🏽".normalizingSkinTone(to: .light), "👋🏻")
    }

    func test_replaceTone_mediumToSame() {
        XCTAssertEqual("👋🏽".normalizingSkinTone(to: .medium), "👋🏽")
    }

    func test_addTone_bareBaseToDark() {
        XCTAssertEqual("👋".normalizingSkinTone(to: .dark), "👋🏿")
    }

    func test_addTone_nonModifierBaseReturnsBase() {
        // 😊 is not Emoji_Modifier_Base → no modifier appended
        XCTAssertEqual("😊".normalizingSkinTone(to: .dark), "😊")
    }

    // MARK: - ZWJ sequences → unchanged

    func test_zwj_skinToneHair_stripUnchanged() {
        let emoji = "👩🏽‍🦰"
        XCTAssertEqual(emoji.normalizingSkinTone(to: .strip), emoji)
    }

    func test_zwj_family_darkUnchanged() {
        let emoji = "👨‍👩‍👧‍👦"
        XCTAssertEqual(emoji.normalizingSkinTone(to: .dark), emoji)
    }

    func test_zwj_profession_lightUnchanged() {
        let emoji = "👩‍💻"
        XCTAssertEqual(emoji.normalizingSkinTone(to: .light), emoji)
    }

    // MARK: - Edge cases

    func test_emptyString() {
        XCTAssertEqual("".normalizingSkinTone(to: .strip), "")
    }
}
