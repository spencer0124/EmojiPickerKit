import SwiftUI
import EmojiPickerKit

struct ContentView: View {
    // MARK: - Single mode
    @State private var showSinglePicker = false
    @State private var selectedEmoji: String = "😊"

    // MARK: - Multiple mode
    @State private var showMultiplePicker = false
    @State private var collectedEmojis: [String] = []

    // MARK: - Config options
    @State private var showConfigPicker = false
    @State private var configEmoji: String = "👋🏽"
    @State private var skinToneMode: Int = 0

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
            }
            .navigationTitle("EmojiPickerKit")
            // ─── Modifiers ───
            .emojiKeyboard(isPresented: $showSinglePicker, mode: .single, onDismiss: {
                print("Single picker dismissed")
            }) { emoji in
                selectedEmoji = emoji
            }
            .emojiKeyboard(isPresented: $showMultiplePicker, mode: .multiple(), onDismiss: {
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

    private var currentConfig: EmojiKeyboardConfiguration {
        let normalization: EmojiSkinToneNormalization? = switch skinToneMode {
        case 1: .strip
        case 2: .light
        case 3: .mediumLight
        case 4: .medium
        case 5: .mediumDark
        case 6: .dark
        default: nil
        }
        return EmojiKeyboardConfiguration(normalizeSkinTone: normalization)
    }
}

#Preview {
    ContentView()
}
