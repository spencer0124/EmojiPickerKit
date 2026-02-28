import XCTest
@testable import EmojiPickerKit

final class Step7_EmojiHelperTests: XCTestCase {

    // MARK: - emojis

    func test_emojis_mixedString() {
        XCTAssertEqual("Hello 😊 World 🔥".emojis, ["😊", "🔥"])
    }

    func test_emojis_emojiOnly() {
        XCTAssertEqual("😊🔥".emojis, ["😊", "🔥"])
    }

    func test_emojis_noEmoji() {
        XCTAssertEqual("no emoji here".emojis, [])
    }

    func test_emojis_emptyString() {
        XCTAssertEqual("".emojis, [])
    }

    func test_emojis_zwjSequence() {
        XCTAssertEqual("Hi 👨‍👩‍👧‍👦 bye".emojis, ["👨‍👩‍👧‍👦"])
    }

    // MARK: - emojiCount

    func test_emojiCount_basic() {
        XCTAssertEqual("😊🔥".emojiCount, 2)
    }

    func test_emojiCount_zwjAsOne() {
        XCTAssertEqual("👨‍👩‍👧‍👦".emojiCount, 1)
    }

    func test_emojiCount_empty() {
        XCTAssertEqual("".emojiCount, 0)
    }

    func test_emojiCount_mixed() {
        XCTAssertEqual("Hello 😊 World 🔥".emojiCount, 2)
    }

    // MARK: - removingEmojis

    func test_removingEmojis_mixedString() {
        XCTAssertEqual("Hello 😊 World".removingEmojis, "Hello  World")
    }

    func test_removingEmojis_emojiOnly() {
        XCTAssertEqual("😊🔥".removingEmojis, "")
    }

    func test_removingEmojis_noEmoji() {
        XCTAssertEqual("no emoji here".removingEmojis, "no emoji here")
    }

    func test_removingEmojis_empty() {
        XCTAssertEqual("".removingEmojis, "")
    }

    // MARK: - strippingEmojis

    func test_strippingEmojis_collapsesSpaces() {
        XCTAssertEqual("Hello 😊 World".strippingEmojis, "Hello World")
    }

    func test_strippingEmojis_trimsEdges() {
        XCTAssertEqual("😊 Hello".strippingEmojis, "Hello")
    }

    func test_strippingEmojis_emojiOnly() {
        XCTAssertEqual("😊🔥".strippingEmojis, "")
    }

    func test_strippingEmojis_multipleSpaces() {
        XCTAssertEqual("A 😊 B 🔥 C".strippingEmojis, "A B C")
    }

    // MARK: - emojiSkinTone

    func test_emojiSkinTone_light() {
        XCTAssertEqual("👋🏻".emojiSkinTone, .light)
    }

    func test_emojiSkinTone_mediumLight() {
        XCTAssertEqual("👋🏼".emojiSkinTone, .mediumLight)
    }

    func test_emojiSkinTone_medium() {
        XCTAssertEqual("👋🏽".emojiSkinTone, .medium)
    }

    func test_emojiSkinTone_mediumDark() {
        XCTAssertEqual("👋🏾".emojiSkinTone, .mediumDark)
    }

    func test_emojiSkinTone_dark() {
        XCTAssertEqual("👋🏿".emojiSkinTone, .dark)
    }

    func test_emojiSkinTone_noTone() {
        XCTAssertNil("👋".emojiSkinTone)
    }

    func test_emojiSkinTone_nonEmoji() {
        XCTAssertNil("hello".emojiSkinTone)
    }

    func test_emojiSkinTone_zwjWithTone() {
        XCTAssertEqual("👩🏽‍🦰".emojiSkinTone, .medium)
    }

    // MARK: - emojiComponents

    func test_emojiComponents_zwjFamily() {
        XCTAssertEqual("👨‍👩‍👧‍👦".emojiComponents, ["👨", "👩", "👧", "👦"])
    }

    func test_emojiComponents_profession() {
        XCTAssertEqual("👩‍💻".emojiComponents, ["👩", "💻"])
    }

    func test_emojiComponents_nonZwj() {
        XCTAssertEqual("😊".emojiComponents, ["😊"])
    }

    func test_emojiComponents_nonEmoji() {
        XCTAssertEqual("hello".emojiComponents, [])
    }

    func test_emojiComponents_empty() {
        XCTAssertEqual("".emojiComponents, [])
    }
}
