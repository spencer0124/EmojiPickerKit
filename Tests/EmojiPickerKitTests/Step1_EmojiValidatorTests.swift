import XCTest
@testable import EmojiPickerKit

final class Step1_EmojiValidatorTests: XCTestCase {

    // MARK: - containsOnlyEmoji == true

    func test_containsOnlyEmoji_standardEmoji() {
        XCTAssertTrue("😊".containsOnlyEmoji)
        XCTAssertTrue("🔥".containsOnlyEmoji)
    }

    func test_containsOnlyEmoji_heartWithVS16() {
        // ❤️ = U+2764 + U+FE0F (text-presentation-default + VS-16)
        XCTAssertTrue("❤️".containsOnlyEmoji)
    }

    func test_containsOnlyEmoji_skinToneModifier() {
        XCTAssertTrue("👋🏽".containsOnlyEmoji)
    }

    func test_containsOnlyEmoji_regionalIndicatorFlags() {
        XCTAssertTrue("🇰🇷".containsOnlyEmoji)
        XCTAssertTrue("🇺🇸".containsOnlyEmoji)
    }

    func test_containsOnlyEmoji_zwjSequences() {
        XCTAssertTrue("👨‍👩‍👧‍👦".containsOnlyEmoji) // family
        XCTAssertTrue("👩‍💻".containsOnlyEmoji)       // woman technologist
        XCTAssertTrue("👩🏽‍🦰".containsOnlyEmoji)      // woman medium skin red hair
        XCTAssertTrue("🏳️‍🌈".containsOnlyEmoji)      // rainbow flag
    }

    func test_containsOnlyEmoji_keycapSequences() {
        XCTAssertTrue("1️⃣".containsOnlyEmoji)
        XCTAssertTrue("0️⃣".containsOnlyEmoji)
        XCTAssertTrue("9️⃣".containsOnlyEmoji)
        XCTAssertTrue("#️⃣".containsOnlyEmoji)
        XCTAssertTrue("*️⃣".containsOnlyEmoji)
    }

    func test_containsOnlyEmoji_textPresentationDefaultWithVS16() {
        XCTAssertTrue("©️".containsOnlyEmoji)  // U+00A9 + U+FE0F
        XCTAssertTrue("™️".containsOnlyEmoji)  // U+2122 + U+FE0F
        XCTAssertTrue("▶️".containsOnlyEmoji)
        XCTAssertTrue("↩️".containsOnlyEmoji)
    }

    func test_containsOnlyEmoji_multipleEmojis() {
        XCTAssertTrue("😊😊".containsOnlyEmoji)
        XCTAssertTrue("🇰🇷🇺🇸".containsOnlyEmoji)
    }

    // MARK: - containsOnlyEmoji == false

    func test_containsOnlyEmoji_emptyString() {
        XCTAssertFalse("".containsOnlyEmoji)
    }

    func test_containsOnlyEmoji_plainText() {
        XCTAssertFalse("abc".containsOnlyEmoji)
        XCTAssertFalse(" ".containsOnlyEmoji)
    }

    func test_containsOnlyEmoji_plainDigits() {
        XCTAssertFalse("1".containsOnlyEmoji)
        XCTAssertFalse("123".containsOnlyEmoji)
    }

    func test_containsOnlyEmoji_keycapBaseAlone() {
        XCTAssertFalse("#".containsOnlyEmoji)
        XCTAssertFalse("*".containsOnlyEmoji)
    }

    func test_containsOnlyEmoji_textPresentationWithoutVS16() {
        XCTAssertFalse("\u{00A9}".containsOnlyEmoji) // © without VS-16
        XCTAssertFalse("\u{2122}".containsOnlyEmoji) // ™ without VS-16
    }

    func test_containsOnlyEmoji_mixedEmojiAndText() {
        XCTAssertFalse("😊abc".containsOnlyEmoji)
        XCTAssertFalse("😊 😊".containsOnlyEmoji)
    }

    func test_containsOnlyEmoji_vs16Standalone() {
        // VS-16 alone should NOT be emoji
        XCTAssertFalse("\u{FE0F}".containsOnlyEmoji)
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
