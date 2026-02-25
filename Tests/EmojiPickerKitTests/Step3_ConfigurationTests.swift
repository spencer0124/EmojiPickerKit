import XCTest
import UIKit
@testable import EmojiPickerKit

final class Step3_ConfigurationTests: XCTestCase {

    // MARK: - Default values

    func test_default_emojiOnlyIsTrue() {
        XCTAssertTrue(EmojiKeyboardConfiguration.default.emojiOnly)
    }

    func test_default_normalizeSkinToneIsNil() {
        XCTAssertNil(EmojiKeyboardConfiguration.default.normalizeSkinTone)
    }

    func test_default_hapticFeedbackIsLight() {
        XCTAssertEqual(EmojiKeyboardConfiguration.default.hapticFeedback, .light)
    }

    func test_default_disableDictationIsFalse() {
        XCTAssertFalse(EmojiKeyboardConfiguration.default.disableDictation)
    }

    // MARK: - Custom initialization

    func test_custom_emojiOnlyFalse() {
        let config = EmojiKeyboardConfiguration(emojiOnly: false)
        XCTAssertFalse(config.emojiOnly)
    }

    func test_custom_normalizeSkinToneStrip() {
        let config = EmojiKeyboardConfiguration(normalizeSkinTone: .strip)
        XCTAssertEqual(config.normalizeSkinTone, .strip)
    }

    func test_custom_normalizeSkinToneDark() {
        let config = EmojiKeyboardConfiguration(normalizeSkinTone: .dark)
        XCTAssertEqual(config.normalizeSkinTone, .dark)
    }

    func test_custom_hapticFeedbackNil() {
        let config = EmojiKeyboardConfiguration(hapticFeedback: nil)
        XCTAssertNil(config.hapticFeedback)
    }

    func test_custom_hapticFeedbackHeavy() {
        let config = EmojiKeyboardConfiguration(hapticFeedback: .heavy)
        XCTAssertEqual(config.hapticFeedback, .heavy)
    }

    func test_custom_disableDictationTrue() {
        let config = EmojiKeyboardConfiguration(disableDictation: true)
        XCTAssertTrue(config.disableDictation)
    }

    // MARK: - Consistency

    func test_staticDefault_matchesDefaultInit() {
        let a = EmojiKeyboardConfiguration.default
        let b = EmojiKeyboardConfiguration()
        XCTAssertEqual(a.emojiOnly, b.emojiOnly)
        XCTAssertEqual(a.normalizeSkinTone, b.normalizeSkinTone)
        XCTAssertEqual(a.hapticFeedback, b.hapticFeedback)
        XCTAssertEqual(a.disableDictation, b.disableDictation)
    }
}
