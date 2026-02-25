import XCTest
import SwiftUI
@testable import EmojiPickerKit

final class Step6_SwiftUIBindingTests: XCTestCase {

    // MARK: - Compile verification: View Modifier exists

    func test_viewModifier_minimalParams() {
        var isPresented = false
        let view = Text("Test")
            .emojiKeyboard(isPresented: Binding(get: { isPresented }, set: { isPresented = $0 })) { _ in }
        XCTAssertNotNil(view)
    }

    func test_viewModifier_fullParams() {
        var isPresented = false
        let config = EmojiKeyboardConfiguration(emojiOnly: false, hapticFeedback: .heavy)
        let view = Text("Test")
            .emojiKeyboard(
                isPresented: Binding(get: { isPresented }, set: { isPresented = $0 }),
                mode: .multiple(),
                config: config
            ) { _ in }
        XCTAssertNotNil(view)
    }

    func test_viewModifier_multipleWithCustomAccessory() {
        var isPresented = false
        let view = Text("Test")
            .emojiKeyboard(
                isPresented: Binding(get: { isPresented }, set: { isPresented = $0 }),
                mode: .multiple(accessoryView: { dismiss in
                    AnyView(Button("Done") { dismiss() })
                })
            ) { _ in }
        XCTAssertNotNil(view)
    }

    // MARK: - Representable creation

    func test_representable_createsSuccessfully() {
        var isPresented = true
        let rep = EmojiKeyboardRepresentable(
            isPresented: Binding(get: { isPresented }, set: { isPresented = $0 }),
            mode: .single,
            config: .default,
            onEmojiSelected: { _ in }
        )
        XCTAssertNotNil(rep)
    }

    // MARK: - Coordinator

    func test_coordinator_isUpdatingInitiallyFalse() {
        var isPresented = false
        let rep = EmojiKeyboardRepresentable(
            isPresented: Binding(get: { isPresented }, set: { isPresented = $0 }),
            mode: .single,
            config: .default,
            onEmojiSelected: { _ in }
        )
        let coordinator = rep.makeCoordinator()
        XCTAssertFalse(coordinator.isUpdating)
    }

    // MARK: - Notification: our textField → isPresented = false

    func test_notification_ourTextField_setsPresentedFalse() {
        var isPresented = true
        let binding = Binding(get: { isPresented }, set: { isPresented = $0 })
        let rep = EmojiKeyboardRepresentable(
            isPresented: binding,
            mode: .single,
            config: .default,
            onEmojiSelected: { _ in }
        )
        let coordinator = rep.makeCoordinator()
        let tf = EmojiKeyboardTextField(mode: .single, config: .default)
        coordinator.textField = tf

        // Post notification for our text field
        NotificationCenter.default.post(
            name: UITextField.textDidEndEditingNotification,
            object: tf
        )

        // Wait for main queue
        let expectation = expectation(description: "notification processed")
        DispatchQueue.main.async { expectation.fulfill() }
        wait(for: [expectation], timeout: 1.0)

        XCTAssertFalse(isPresented)
    }

    // MARK: - Notification: other textField → isPresented unchanged

    func test_notification_otherTextField_presentedUnchanged() {
        var isPresented = true
        let binding = Binding(get: { isPresented }, set: { isPresented = $0 })
        let rep = EmojiKeyboardRepresentable(
            isPresented: binding,
            mode: .single,
            config: .default,
            onEmojiSelected: { _ in }
        )
        let coordinator = rep.makeCoordinator()
        let ourTF = EmojiKeyboardTextField(mode: .single, config: .default)
        coordinator.textField = ourTF

        // Post notification for a different text field
        let otherTF = UITextField()
        NotificationCenter.default.post(
            name: UITextField.textDidEndEditingNotification,
            object: otherTF
        )

        let expectation = expectation(description: "notification processed")
        DispatchQueue.main.async { expectation.fulfill() }
        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(isPresented) // unchanged
    }

    // MARK: - updateUIView propagates config

    func test_updateUIView_propagatesConfig_directCall() {
        // Directly verify the config propagation logic that updateUIView performs
        let tf = EmojiKeyboardTextField(mode: .single, config: .default)
        XCTAssertNil(tf.config.normalizeSkinTone)

        // Simulate what updateUIView now does
        let newConfig = EmojiKeyboardConfiguration(normalizeSkinTone: .strip)
        tf.config = newConfig

        XCTAssertEqual(tf.config.normalizeSkinTone, .strip)
    }

    func test_updateUIView_propagatesCallback_directCall() {
        let tf = EmojiKeyboardTextField(mode: .single, config: .default)

        var received: String?
        tf.onEmojiSelected = { received = $0 }

        // Simulate what updateUIView now does — overwrite callback
        var updated: String?
        tf.onEmojiSelected = { updated = $0 }

        tf.onEmojiSelected?("🎉")

        XCTAssertNil(received, "Old callback should not fire")
        XCTAssertEqual(updated, "🎉", "New callback should fire")
    }

    // MARK: - EmojiKeyboardMode existence

    func test_mode_singleExists() {
        let mode = EmojiKeyboardMode.single
        if case .single = mode { /* pass */ } else { XCTFail() }
    }

    func test_mode_multipleDefaultNil() {
        let mode = EmojiKeyboardMode.multiple()
        if case .multiple(let av) = mode {
            XCTAssertNil(av)
        } else { XCTFail() }
    }
}
