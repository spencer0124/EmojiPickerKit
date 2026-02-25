import XCTest
@testable import EmojiPickerKit

final class Step1_EmojiValidatorTests: XCTestCase {

    // MARK: - isEmoji == true

    func test_isEmoji_standardEmoji() {
        XCTAssertTrue("😊".isEmoji)
        XCTAssertTrue("🔥".isEmoji)
    }

    func test_isEmoji_heartWithVS16() {
        // ❤️ = U+2764 + U+FE0F (text-presentation-default + VS-16)
        XCTAssertTrue("❤️".isEmoji)
    }

    func test_isEmoji_skinToneModifier() {
        XCTAssertTrue("👋🏽".isEmoji)
    }

    func test_isEmoji_regionalIndicatorFlags() {
        XCTAssertTrue("🇰🇷".isEmoji)
        XCTAssertTrue("🇺🇸".isEmoji)
    }

    func test_isEmoji_zwjSequences() {
        XCTAssertTrue("👨‍👩‍👧‍👦".isEmoji) // family
        XCTAssertTrue("👩‍💻".isEmoji)       // woman technologist
        XCTAssertTrue("👩🏽‍🦰".isEmoji)      // woman medium skin red hair
        XCTAssertTrue("🏳️‍🌈".isEmoji)      // rainbow flag
    }

    func test_isEmoji_keycapSequences() {
        XCTAssertTrue("1️⃣".isEmoji)
        XCTAssertTrue("0️⃣".isEmoji)
        XCTAssertTrue("9️⃣".isEmoji)
        XCTAssertTrue("#️⃣".isEmoji)
        XCTAssertTrue("*️⃣".isEmoji)
    }

    func test_isEmoji_textPresentationDefaultWithVS16() {
        XCTAssertTrue("©️".isEmoji)  // U+00A9 + U+FE0F
        XCTAssertTrue("™️".isEmoji)  // U+2122 + U+FE0F
        XCTAssertTrue("▶️".isEmoji)
        XCTAssertTrue("↩️".isEmoji)
    }

    func test_isEmoji_multipleEmojis() {
        XCTAssertTrue("😊😊".isEmoji)
        XCTAssertTrue("🇰🇷🇺🇸".isEmoji)
    }

    // MARK: - isEmoji == false

    func test_isEmoji_emptyString() {
        XCTAssertFalse("".isEmoji)
    }

    func test_isEmoji_plainText() {
        XCTAssertFalse("abc".isEmoji)
        XCTAssertFalse(" ".isEmoji)
    }

    func test_isEmoji_plainDigits() {
        XCTAssertFalse("1".isEmoji)
        XCTAssertFalse("123".isEmoji)
    }

    func test_isEmoji_keycapBaseAlone() {
        XCTAssertFalse("#".isEmoji)
        XCTAssertFalse("*".isEmoji)
    }

    func test_isEmoji_textPresentationWithoutVS16() {
        XCTAssertFalse("\u{00A9}".isEmoji) // © without VS-16
        XCTAssertFalse("\u{2122}".isEmoji) // ™ without VS-16
    }

    func test_isEmoji_mixedEmojiAndText() {
        XCTAssertFalse("😊abc".isEmoji)
        XCTAssertFalse("😊 😊".isEmoji)
    }

    func test_isEmoji_vs16Standalone() {
        // VS-16 alone should NOT be emoji
        XCTAssertFalse("\u{FE0F}".isEmoji)
    }

    // MARK: - isSingleEmoji

    func test_isSingleEmoji_true() {
        XCTAssertTrue("😊".isSingleEmoji)
        XCTAssertTrue("👨‍👩‍👧‍👦".isSingleEmoji) // ZWJ family = 1 Character
        XCTAssertTrue("🇰🇷".isSingleEmoji)
        XCTAssertTrue("1️⃣".isSingleEmoji)
    }

    func test_isSingleEmoji_false_multiple() {
        XCTAssertFalse("😊😊".isSingleEmoji)
    }

    func test_isSingleEmoji_false_nonEmoji() {
        XCTAssertFalse("a".isSingleEmoji)
        XCTAssertFalse("1".isSingleEmoji)
        XCTAssertFalse("".isSingleEmoji)
        XCTAssertFalse("\u{00A9}".isSingleEmoji) // © without VS-16
    }
}
