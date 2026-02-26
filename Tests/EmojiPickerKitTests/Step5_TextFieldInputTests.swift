import XCTest
import UIKit
@testable import EmojiPickerKit

final class Step5_TextFieldInputTests: XCTestCase {

    /// Helper: invoke shouldChangeCharactersIn on the text field's delegate.
    private func simulateInput(_ text: String, on tf: EmojiKeyboardTextField) -> Bool {
        tf.delegate?.textField?(
            tf,
            shouldChangeCharactersIn: NSRange(location: 0, length: 0),
            replacementString: text
        ) ?? true
    }

    // MARK: - Always returns false

    func test_alwaysReturnsFalse_emoji() {
        let tf = EmojiKeyboardTextField(mode: .multiple(), config: .default)
        XCTAssertFalse(simulateInput("😊", on: tf))
    }

    func test_alwaysReturnsFalse_text() {
        let tf = EmojiKeyboardTextField(mode: .multiple(), config: .default)
        XCTAssertFalse(simulateInput("abc", on: tf))
    }

    func test_alwaysReturnsFalse_empty() {
        let tf = EmojiKeyboardTextField(mode: .multiple(), config: .default)
        XCTAssertFalse(simulateInput("", on: tf))
    }

    // MARK: - emojiOnly = true (default)

    func test_emojiOnly_emojiCallsCallback() {
        let tf = EmojiKeyboardTextField(mode: .multiple(), config: .default)
        var received: String?
        tf.onEmojiSelected = { received = $0 }
        _ = simulateInput("😊", on: tf)
        XCTAssertEqual(received, "😊")
    }

    func test_emojiOnly_zwjCallsCallback() {
        let tf = EmojiKeyboardTextField(mode: .multiple(), config: .default)
        var received: String?
        tf.onEmojiSelected = { received = $0 }
        _ = simulateInput("👨‍👩‍👧‍👦", on: tf)
        XCTAssertEqual(received, "👨‍👩‍👧‍👦")
    }

    func test_emojiOnly_flagCallsCallback() {
        let tf = EmojiKeyboardTextField(mode: .multiple(), config: .default)
        var received: String?
        tf.onEmojiSelected = { received = $0 }
        _ = simulateInput("🇰🇷", on: tf)
        XCTAssertEqual(received, "🇰🇷")
    }

    func test_emojiOnly_keycapCallsCallback() {
        let tf = EmojiKeyboardTextField(mode: .multiple(), config: .default)
        var received: String?
        tf.onEmojiSelected = { received = $0 }
        _ = simulateInput("1️⃣", on: tf)
        XCTAssertEqual(received, "1️⃣")
    }

    func test_emojiOnly_textDoesNotCallCallback() {
        let tf = EmojiKeyboardTextField(mode: .multiple(), config: .default)
        var received: String?
        tf.onEmojiSelected = { received = $0 }
        _ = simulateInput("abc", on: tf)
        XCTAssertNil(received)
    }

    func test_emojiOnly_digitDoesNotCallCallback() {
        let tf = EmojiKeyboardTextField(mode: .multiple(), config: .default)
        var received: String?
        tf.onEmojiSelected = { received = $0 }
        _ = simulateInput("1", on: tf)
        XCTAssertNil(received)
    }

    func test_emojiOnly_multipleEmojisBlocked_singleMode() {
        // single mode uses isSingleEmoji → "😊😊" blocked
        let tf = EmojiKeyboardTextField(mode: .single, config: .default)
        var received: String?
        tf.onEmojiSelected = { received = $0 }
        _ = simulateInput("😊😊", on: tf)
        XCTAssertNil(received)
    }

    func test_emojiOnly_emptyStringNoCallback() {
        let tf = EmojiKeyboardTextField(mode: .multiple(), config: .default)
        var received: String?
        tf.onEmojiSelected = { received = $0 }
        _ = simulateInput("", on: tf)
        XCTAssertNil(received)
    }

    // MARK: - emojiOnly = false

    func test_emojiOnlyFalse_textCallsCallback() {
        let config = EmojiKeyboardConfiguration(emojiOnly: false)
        let tf = EmojiKeyboardTextField(mode: .multiple(), config: config)
        var received: String?
        tf.onEmojiSelected = { received = $0 }
        _ = simulateInput("abc", on: tf)
        XCTAssertEqual(received, "abc")
    }

    // MARK: - normalizeSkinTone

    func test_normalize_stripRemovesTone() {
        let config = EmojiKeyboardConfiguration(normalizeSkinTone: .strip)
        let tf = EmojiKeyboardTextField(mode: .multiple(), config: config)
        var received: String?
        tf.onEmojiSelected = { received = $0 }
        _ = simulateInput("👋🏽", on: tf)
        XCTAssertEqual(received, "👋")
    }

    func test_normalize_darkReplacesTone() {
        let config = EmojiKeyboardConfiguration(normalizeSkinTone: .dark)
        let tf = EmojiKeyboardTextField(mode: .multiple(), config: config)
        var received: String?
        tf.onEmojiSelected = { received = $0 }
        _ = simulateInput("👋🏽", on: tf)
        XCTAssertEqual(received, "👋🏿")
    }

    func test_normalize_nilPassesThrough() {
        let config = EmojiKeyboardConfiguration(normalizeSkinTone: nil)
        let tf = EmojiKeyboardTextField(mode: .multiple(), config: config)
        var received: String?
        tf.onEmojiSelected = { received = $0 }
        _ = simulateInput("👋🏽", on: tf)
        XCTAssertEqual(received, "👋🏽")
    }

    func test_normalize_zwjStripRemovesTone() {
        let config = EmojiKeyboardConfiguration(normalizeSkinTone: .strip)
        let tf = EmojiKeyboardTextField(mode: .multiple(), config: config)
        var received: String?
        tf.onEmojiSelected = { received = $0 }
        _ = simulateInput("👩🏽‍🦰", on: tf)
        XCTAssertEqual(received, "👩‍🦰")
    }

    func test_normalize_zwjDarkReplacesTone() {
        let config = EmojiKeyboardConfiguration(normalizeSkinTone: .dark)
        let tf = EmojiKeyboardTextField(mode: .multiple(), config: config)
        var received: String?
        tf.onEmojiSelected = { received = $0 }
        _ = simulateInput("👩🏽‍🦰", on: tf)
        XCTAssertEqual(received, "👩🏿‍🦰")
    }

    func test_normalize_zwjNilPassesThrough() {
        let config = EmojiKeyboardConfiguration(normalizeSkinTone: nil)
        let tf = EmojiKeyboardTextField(mode: .multiple(), config: config)
        var received: String?
        tf.onEmojiSelected = { received = $0 }
        _ = simulateInput("👩🏽‍🦰", on: tf)
        XCTAssertEqual(received, "👩🏽‍🦰")
    }

    // MARK: - Callback invocation

    func test_callback_calledMultipleTimes() {
        let tf = EmojiKeyboardTextField(mode: .multiple(), config: .default)
        var count = 0
        tf.onEmojiSelected = { _ in count += 1 }
        _ = simulateInput("😊", on: tf)
        _ = simulateInput("🔥", on: tf)
        XCTAssertEqual(count, 2)
    }

    func test_callback_nilDoesNotCrash() {
        let tf = EmojiKeyboardTextField(mode: .multiple(), config: .default)
        tf.onEmojiSelected = nil
        _ = simulateInput("😊", on: tf)
        // no crash = pass
    }

    // MARK: - Single mode dismiss

    func test_singleMode_resignsAfterEmoji() {
        let tf = EmojiKeyboardTextField(mode: .single, config: .default)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        window.addSubview(tf)
        window.makeKeyAndVisible()
        tf.becomeFirstResponder()

        tf.onEmojiSelected = { _ in }
        _ = simulateInput("😊", on: tf)

        // resignFirstResponder is async — wait briefly
        let expectation = expectation(description: "resign")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(tf.isFirstResponder)
    }

    // MARK: - Haptic (no crash)

    func test_hapticFeedback_noCrash() {
        let config = EmojiKeyboardConfiguration(hapticFeedback: .heavy)
        let tf = EmojiKeyboardTextField(mode: .multiple(), config: config)
        tf.onEmojiSelected = { _ in }
        _ = simulateInput("😊", on: tf)
        // reaching here = no crash
    }
}
