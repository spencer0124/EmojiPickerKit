import UIKit
import SwiftUI
import os.log

/// Defines how the emoji keyboard operates.
public enum EmojiKeyboardMode {
    /// Single emoji selection: keyboard dismisses after one emoji is entered.
    case single
    /// Multiple emoji selection: keyboard stays open. Optional custom accessory view.
    case multiple(accessoryView: ((_ dismiss: @escaping () -> Void) -> AnyView)? = nil)
}

/// A UITextField configured to show the system emoji keyboard.
public final class EmojiKeyboardTextField: UITextField {

    // MARK: - Constants

    private static let emojiKeyboardRawValue = 124
    private static let logger = Logger(subsystem: "EmojiPickerKit", category: "EmojiKeyboardTextField")

    // MARK: - Public properties

    public let mode: EmojiKeyboardMode
    public var config: EmojiKeyboardConfiguration

    /// Callback invoked when an emoji is entered.
    public var onEmojiSelected: ((String) -> Void)?

    /// Callback invoked when the keyboard is dismissed.
    public var onDismiss: (() -> Void)?

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

    @discardableResult
    public func present() -> Bool {
        assert(Thread.isMainThread, "present() must be called on the main thread")
        applyDictationSetting()
        hapticGenerator?.prepare()
        return becomeFirstResponder()
    }

    public func dismiss() {
        assert(Thread.isMainThread, "dismiss() must be called on the main thread")
        resignFirstResponder()
    }

    @discardableResult
    override public func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result { onDismiss?() }
        return result
    }

    // MARK: - Setup

    private func setup() {
        // Undocumented emoji keyboard type used by Apple's Reminders app.
        // This is NOT a public UIKeyboardType case. If Apple changes or removes
        // this raw value in a future iOS version, a standard keyboard will
        // appear instead of the emoji keyboard.
        if let emojiType = UIKeyboardType(rawValue: Self.emojiKeyboardRawValue) {
            keyboardType = emojiType
        } else {
            keyboardType = .default
            Self.logger.warning("Emoji keyboard type (rawValue \(Self.emojiKeyboardRawValue)) unavailable — falling back to default keyboard")
        }
        alpha = 0
        delegate = self

        // Accessibility — hide from VoiceOver
        isAccessibilityElement = false
        accessibilityElementsHidden = true

        applyDictationSetting()
        setupAccessoryView()
    }

    /// Uses the same private API that Apple's Reminders app uses to hide the
    /// dictation button on the emoji keyboard.
    private func applyDictationSetting() {
        let selector = NSSelectorFromString("setForceDisableDictation:")
        guard let imp = class_getMethodImplementation(object_getClass(self), selector) else { return }
        typealias SetBoolIMP = @convention(c) (AnyObject, Selector, Bool) -> Void
        let function = unsafeBitCast(imp, to: SetBoolIMP.self)
        function(self, selector, config.disableDictation)
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
            Button("Done") { dismiss() }
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

        // emojiOnly filter
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
