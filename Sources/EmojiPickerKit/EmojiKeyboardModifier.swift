import SwiftUI
import UIKit

// MARK: - UIViewRepresentable

/// A SwiftUI wrapper around `EmojiKeyboardTextField`.
public struct EmojiKeyboardRepresentable: UIViewRepresentable {
    @Binding var isPresented: Bool
    let mode: EmojiKeyboardMode
    let config: EmojiKeyboardConfiguration
    let onEmojiSelected: (String) -> Void
    let onDismiss: (() -> Void)?

    public init(
        isPresented: Binding<Bool>,
        mode: EmojiKeyboardMode = .single,
        config: EmojiKeyboardConfiguration = .default,
        onDismiss: (() -> Void)? = nil,
        onEmojiSelected: @escaping (String) -> Void
    ) {
        self._isPresented = isPresented
        self.mode = mode
        self.config = config
        self.onDismiss = onDismiss
        self.onEmojiSelected = onEmojiSelected
    }

    public func makeUIView(context: Context) -> EmojiKeyboardTextField {
        let tf = EmojiKeyboardTextField(mode: mode, config: config)
        tf.onEmojiSelected = onEmojiSelected
        tf.onDismiss = onDismiss
        context.coordinator.textField = tf
        return tf
    }

    public func updateUIView(_ uiView: EmojiKeyboardTextField, context: Context) {
        // Sync config and callbacks on every SwiftUI update
        uiView.config = config
        uiView.onEmojiSelected = onEmojiSelected
        uiView.onDismiss = onDismiss

        let coordinator = context.coordinator
        guard !coordinator.isUpdating else { return }

        if isPresented && !uiView.isFirstResponder {
            uiView.present()
        } else if !isPresented && uiView.isFirstResponder {
            uiView.dismiss()
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }

    // MARK: - Coordinator

    public class Coordinator: NSObject {
        @Binding var isPresented: Bool
        weak var textField: EmojiKeyboardTextField?

        /// Loop prevention flag.
        /// updateUIView → dismiss → textDidEndEditing → isPresented = false → updateUIView loop
        var isUpdating = false

        init(isPresented: Binding<Bool>) {
            _isPresented = isPresented
            super.init()

            // UIKit → binding: detect keyboard dismiss via notification
            // (avoids delegate conflict with shouldChangeCharactersIn)
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardDidResign(_:)),
                name: UITextField.textDidEndEditingNotification,
                object: nil
            )
        }

        @objc private func keyboardDidResign(_ notification: Notification) {
            guard let tf = notification.object as? EmojiKeyboardTextField,
                  tf === textField else { return }

            isUpdating = true
            isPresented = false
            DispatchQueue.main.async { [weak self] in
                self?.isUpdating = false
            }
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

// MARK: - View Modifier

struct EmojiKeyboardModifier: ViewModifier {
    @Binding var isPresented: Bool
    let mode: EmojiKeyboardMode
    let config: EmojiKeyboardConfiguration
    let onDismiss: (() -> Void)?
    let onEmojiSelected: (String) -> Void

    func body(content: Content) -> some View {
        content
            .background(
                EmojiKeyboardRepresentable(
                    isPresented: $isPresented,
                    mode: mode,
                    config: config,
                    onDismiss: onDismiss,
                    onEmojiSelected: onEmojiSelected
                )
                .frame(width: 0, height: 0)
            )
    }
}

// MARK: - View Extension

public extension View {
    /// Attaches an emoji keyboard to this view.
    ///
    /// - Parameters:
    ///   - isPresented: Binding controlling keyboard visibility.
    ///   - mode: `.single` or `.multiple()`.
    ///   - config: Keyboard configuration.
    ///   - onDismiss: Optional callback invoked when the keyboard is dismissed.
    ///   - onEmojiSelected: Callback invoked when an emoji is selected.
    func emojiKeyboard(
        isPresented: Binding<Bool>,
        mode: EmojiKeyboardMode = .single,
        config: EmojiKeyboardConfiguration = .default,
        onDismiss: (() -> Void)? = nil,
        onEmojiSelected: @escaping (String) -> Void
    ) -> some View {
        modifier(
            EmojiKeyboardModifier(
                isPresented: isPresented,
                mode: mode,
                config: config,
                onDismiss: onDismiss,
                onEmojiSelected: onEmojiSelected
            )
        )
    }

    /// Attaches an emoji keyboard with a custom accessory view (multiple selection mode).
    ///
    /// - Parameters:
    ///   - isPresented: Binding controlling keyboard visibility.
    ///   - config: Keyboard configuration.
    ///   - onDismiss: Optional callback invoked when the keyboard is dismissed.
    ///   - accessoryView: A custom view displayed above the keyboard. Receives a dismiss closure.
    ///   - onEmojiSelected: Callback invoked when an emoji is selected.
    func emojiKeyboard<AccessoryView: View>(
        isPresented: Binding<Bool>,
        config: EmojiKeyboardConfiguration = .default,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder accessoryView: @escaping (_ dismiss: @escaping () -> Void) -> AccessoryView,
        onEmojiSelected: @escaping (String) -> Void
    ) -> some View {
        emojiKeyboard(
            isPresented: isPresented,
            mode: .multiple(accessoryView: { dismiss in AnyView(accessoryView(dismiss)) }),
            config: config,
            onDismiss: onDismiss,
            onEmojiSelected: onEmojiSelected
        )
    }
}
