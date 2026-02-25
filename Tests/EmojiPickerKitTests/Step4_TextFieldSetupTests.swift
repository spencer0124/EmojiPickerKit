import XCTest
import UIKit
@testable import EmojiPickerKit

final class Step4_TextFieldSetupTests: XCTestCase {

    // MARK: - Keyboard type

    func test_keyboardType_rawValue124() {
        let tf = EmojiKeyboardTextField(mode: .single, config: .default)
        XCTAssertEqual(tf.keyboardType.rawValue, 124)
    }

    // MARK: - Visual properties

    func test_alpha_isZero() {
        let tf = EmojiKeyboardTextField(mode: .single, config: .default)
        XCTAssertEqual(tf.alpha, 0)
    }

    // MARK: - Accessibility

    func test_isAccessibilityElement_false() {
        let tf = EmojiKeyboardTextField(mode: .single, config: .default)
        XCTAssertFalse(tf.isAccessibilityElement)
    }

    func test_accessibilityElementsHidden_true() {
        let tf = EmojiKeyboardTextField(mode: .single, config: .default)
        XCTAssertTrue(tf.accessibilityElementsHidden)
    }

    // MARK: - Delegate

    func test_delegate_isSelf() {
        let tf = EmojiKeyboardTextField(mode: .single, config: .default)
        XCTAssertTrue(tf.delegate === tf)
    }

    // MARK: - Single mode

    func test_singleMode_noAccessoryView() {
        let tf = EmojiKeyboardTextField(mode: .single, config: .default)
        XCTAssertNil(tf.inputAccessoryView)
    }

    // MARK: - Multiple mode (default)

    func test_multipleMode_hasAccessoryView() {
        let tf = EmojiKeyboardTextField(mode: .multiple(), config: .default)
        XCTAssertNotNil(tf.inputAccessoryView)
    }

    func test_multipleMode_accessoryViewHeight44() {
        let tf = EmojiKeyboardTextField(mode: .multiple(), config: .default)
        XCTAssertEqual(tf.inputAccessoryView?.frame.height, 44)
    }

    // MARK: - onEmojiSelected

    func test_onEmojiSelected_initiallyNil() {
        let tf = EmojiKeyboardTextField(mode: .single, config: .default)
        XCTAssertNil(tf.onEmojiSelected)
    }

    // MARK: - shouldChangeCharactersIn returns false

    func test_shouldChangeCharacters_returnsFalse() {
        let tf = EmojiKeyboardTextField(mode: .single, config: .default)
        let result = tf.delegate?.textField?(
            tf,
            shouldChangeCharactersIn: NSRange(location: 0, length: 0),
            replacementString: "😊"
        ) ?? true
        XCTAssertFalse(result)
    }
}
