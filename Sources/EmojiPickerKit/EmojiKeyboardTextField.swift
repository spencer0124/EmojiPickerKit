import UIKit
import SwiftUI

/// Defines how the emoji keyboard operates.
public enum EmojiKeyboardMode {
    /// Single emoji selection: keyboard dismisses after one emoji is entered.
    case single
    /// Multiple emoji selection: keyboard stays open. Optional custom accessory view.
    case multiple(accessoryView: ((_ dismiss: @escaping () -> Void) -> AnyView)? = nil)
}

/// A UITextField configured to show the system emoji keyboard.
public final class EmojiKeyboardTextField: UITextField {

    // MARK: - Public properties

    public let mode: EmojiKeyboardMode
    public var config: EmojiKeyboardConfiguration

    /// Callback invoked when an emoji is entered.
    public var onEmojiSelected: ((String) -> Void)?

    // MARK: - Private

    /// Strong reference to hosting controller — inputAccessoryView is weak
    private var accessoryHostingController: UIHostingController<AnyView>?

    /// Lazy haptic generator — prepare() on present, impactOccurred() on emoji
    private lazy var hapticGenerator: UIImpactFeedbackGenerator? = {
        guard let style = config.hapticFeedback else { return nil }
        return UIImpactFeedbackGenerator(style: style)
    }()

    // MARK: - Init

    public init(mode: EmojiKeyboardMode = .single,
                config: EmojiKeyboardConfiguration = .default) {
        self.mode = mode
        self.config = config
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public methods

    public func present() {
        hapticGenerator?.prepare()
        becomeFirstResponder()
    }

    public func dismiss() {
        resignFirstResponder()
    }

    // MARK: - Setup

    private func setup() {
        keyboardType = UIKeyboardType(rawValue: 124)!
        alpha = 0
        delegate = self

        // Accessibility — hide from VoiceOver
        isAccessibilityElement = false
        accessibilityElementsHidden = true

        setupAccessoryView()
    }

    private func setupAccessoryView() {
        guard case .multiple(let customView) = mode else { return }

        let weakDismiss: () -> Void = { [weak self] in self?.dismiss() }

        let rootView: AnyView = customView?(weakDismiss)
            ?? AnyView(defaultAccessoryView(dismiss: weakDismiss))

        let hc = UIHostingController(rootView: rootView)
        hc.view.frame = CGRect(x: 0, y: 0, width: 0, height: 44)
        hc.view.autoresizingMask = [.flexibleWidth]
        hc.view.backgroundColor = .clear
        accessoryHostingController = hc
        inputAccessoryView = hc.view
    }

    private func defaultAccessoryView(dismiss: @escaping () -> Void) -> some View {
        HStack {
            Spacer()
            Button("완료") { dismiss() }
                .padding(.horizontal)
        }
        .frame(height: 44)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - UITextFieldDelegate

extension EmojiKeyboardTextField: UITextFieldDelegate {
    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        // Empty string = delete backward — ignore
        guard !string.isEmpty else { return false }

        // emojiOnly filter: isSingleEmoji (single/multiple 모두 Phase 1에서는 동일)
        if config.emojiOnly {
            guard string.isSingleEmoji else { return false }
        }

        // normalizeSkinTone
        var result = string
        if let normalization = config.normalizeSkinTone {
            result = result.normalizingSkinTone(to: normalization)
        }

        // hapticFeedback
        hapticGenerator?.impactOccurred()

        // callback
        onEmojiSelected?(result)

        // single mode → dismiss
        if case .single = mode {
            DispatchQueue.main.async { [weak self] in
                self?.resignFirstResponder()
            }
        }

        return false
    }
}
