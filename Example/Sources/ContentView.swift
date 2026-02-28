import SwiftUI
import EmojiPickerKit

struct ContentView: View {
    // MARK: - Single mode
    @State private var showSinglePicker = false
    @State private var selectedEmoji: String = "😊"
    @State private var singleHaptic = true
    @State private var singleDisableDictation = false
    @State private var singleSkinToneMode: Int = 0

    // MARK: - Multiple mode
    @State private var showMultiplePicker = false
    @State private var collectedEmojis: [String] = []
    @State private var multipleHaptic = true
    @State private var multipleDisableDictation = false
    @State private var multipleSkinToneMode: Int = 0

    // MARK: - Config options
    @State private var showConfigPicker = false
    @State private var configEmoji: String = "👋🏽"
    @State private var skinToneMode: Int = 0

    // MARK: - String helpers
    @State private var helperInput: String = "Hello 😊 World 🔥"
    @State private var singleEmojiInput: String = "👨‍👩‍👧‍👦"

    var body: some View {
        NavigationStack {
            List {
                // ─── Single Mode ───
                Section {
                    HStack {
                        Text(selectedEmoji)
                            .font(.system(size: 64))
                        Spacer()
                        Button("Select Emoji") {
                            showSinglePicker = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical, 8)

                    Toggle("Haptic Feedback", isOn: $singleHaptic)
                    Toggle("Disable Dictation", isOn: $singleDisableDictation)
                    Picker("Skin Tone", selection: $singleSkinToneMode) {
                        Text("None").tag(0)
                        Text("Strip").tag(1)
                        Text("Light (🏻)").tag(2)
                        Text("Medium-Light (🏼)").tag(3)
                        Text("Medium (🏽)").tag(4)
                        Text("Medium-Dark (🏾)").tag(5)
                        Text("Dark (🏿)").tag(6)
                    }
                } header: {
                    Text("Single Mode")
                } footer: {
                    Text("Select 1 emoji → auto dismiss (Reminders style)")
                }

                // ─── Multiple Mode ───
                Section {
                    HStack {
                        if collectedEmojis.isEmpty {
                            Text("No emoji selected")
                                .foregroundStyle(.secondary)
                        } else {
                            Text(collectedEmojis.joined())
                                .font(.system(size: 32))
                        }
                        Spacer()
                        Button("Add Emoji") {
                            showMultiplePicker = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical, 8)

                    if !collectedEmojis.isEmpty {
                        Button("Clear", role: .destructive) {
                            collectedEmojis.removeAll()
                        }
                    }

                    Toggle("Haptic Feedback", isOn: $multipleHaptic)
                    Toggle("Disable Dictation", isOn: $multipleDisableDictation)
                    Picker("Skin Tone", selection: $multipleSkinToneMode) {
                        Text("None").tag(0)
                        Text("Strip").tag(1)
                        Text("Light (🏻)").tag(2)
                        Text("Medium-Light (🏼)").tag(3)
                        Text("Medium (🏽)").tag(4)
                        Text("Medium-Dark (🏾)").tag(5)
                        Text("Dark (🏿)").tag(6)
                    }
                } header: {
                    Text("Multiple Mode")
                } footer: {
                    Text("Select multiple emojis. Tap Done to dismiss.")
                }

                // ─── SkinTone Normalization ───
                Section {
                    Picker("Skin Tone", selection: $skinToneMode) {
                        Text("None").tag(0)
                        Text("Strip").tag(1)
                        Text("Light (🏻)").tag(2)
                        Text("Medium-Light (🏼)").tag(3)
                        Text("Medium (🏽)").tag(4)
                        Text("Medium-Dark (🏾)").tag(5)
                        Text("Dark (🏿)").tag(6)
                    }

                    HStack {
                        Text(configEmoji)
                            .font(.system(size: 64))
                        Spacer()
                        Button("Select Emoji") {
                            showConfigPicker = true
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Configuration Test")
                } footer: {
                    Text("Skin tone normalization is applied to selected emojis.")
                }
                // ─── String Helpers ───
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Input")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("Type text with emoji…", text: $helperInput)
                            .textFieldStyle(.roundedBorder)
                    }

                    HelperRow(label: "emojis",
                              value: helperInput.emojis.map(String.init).joined(separator: ", "))
                    HelperRow(label: "emojiCount",
                              value: "\(helperInput.emojiCount)")
                    HelperRow(label: "containsOnlyEmoji",
                              value: "\(helperInput.containsOnlyEmoji)")
                    HelperRow(label: "removingEmojis",
                              value: "\"\(helperInput.removingEmojis)\"")
                    HelperRow(label: "strippingEmojis",
                              value: "\"\(helperInput.strippingEmojis)\"")
                } header: {
                    Text("String Helpers")
                } footer: {
                    Text("Type any text to see helper results update live.")
                }

                // ─── Single Emoji Helpers ───
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Single Emoji Input")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("Enter an emoji…", text: $singleEmojiInput)
                            .textFieldStyle(.roundedBorder)
                    }

                    HelperRow(label: "isSingleEmoji",
                              value: "\(singleEmojiInput.isSingleEmoji)")
                    HelperRow(label: "emojiSkinTone",
                              value: singleEmojiInput.emojiSkinTone.map { "\($0)" } ?? "nil")
                    HelperRow(label: "emojiComponents",
                              value: singleEmojiInput.emojiComponents.isEmpty
                              ? "[]"
                              : singleEmojiInput.emojiComponents.joined(separator: ", "))
                } header: {
                    Text("Single Emoji Helpers")
                } footer: {
                    Text("Enter a single emoji to inspect its properties.")
                }
            }
            .navigationTitle("EmojiPickerKit")
            // ─── Modifiers ───
            .emojiKeyboard(isPresented: $showSinglePicker, mode: .single, config: singleConfig, onDismiss: {
                print("Single picker dismissed")
            }) { emoji in
                selectedEmoji = emoji
            }
            .emojiKeyboard(isPresented: $showMultiplePicker, mode: .multiple(), config: multipleConfig, onDismiss: {
                print("Multiple picker dismissed")
            }) { emoji in
                collectedEmojis.append(emoji)
            }
            .emojiKeyboard(
                isPresented: $showConfigPicker,
                mode: .single,
                config: currentConfig
            ) { emoji in
                configEmoji = emoji
            }
        }
    }

    private var singleConfig: EmojiKeyboardConfiguration {
        makeConfig(haptic: singleHaptic, disableDictation: singleDisableDictation, skinToneMode: singleSkinToneMode)
    }

    private var multipleConfig: EmojiKeyboardConfiguration {
        makeConfig(haptic: multipleHaptic, disableDictation: multipleDisableDictation, skinToneMode: multipleSkinToneMode)
    }

    private var currentConfig: EmojiKeyboardConfiguration {
        makeConfig(haptic: true, disableDictation: false, skinToneMode: skinToneMode)
    }

    private func skinToneNormalization(for mode: Int) -> EmojiSkinToneNormalization? {
        switch mode {
        case 1: .strip
        case 2: .light
        case 3: .mediumLight
        case 4: .medium
        case 5: .mediumDark
        case 6: .dark
        default: nil
        }
    }

    private func makeConfig(haptic: Bool, disableDictation: Bool, skinToneMode: Int) -> EmojiKeyboardConfiguration {
        EmojiKeyboardConfiguration(
            normalizeSkinTone: skinToneNormalization(for: skinToneMode),
            hapticFeedback: haptic ? .light : nil,
            disableDictation: disableDictation
        )
    }
}

private struct HelperRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline.monospaced())
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    ContentView()
}
