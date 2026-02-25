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
    @State private var skinToneMode: Int = 0 // 0=nil, 1=strip, 2=dark

    var body: some View {
        NavigationStack {
            List {
                // ─── Single Mode ───
                Section {
                    HStack {
                        Text(selectedEmoji)
                            .font(.system(size: 64))
                        Spacer()
                        Button("이모지 선택") {
                            showSinglePicker = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Single Mode")
                } footer: {
                    Text("이모지 1개 선택 → 즉시 dismiss (Reminders 스타일)")
                }

                // ─── Multiple Mode ───
                Section {
                    HStack {
                        if collectedEmojis.isEmpty {
                            Text("선택된 이모지 없음")
                                .foregroundStyle(.secondary)
                        } else {
                            Text(collectedEmojis.joined())
                                .font(.system(size: 32))
                        }
                        Spacer()
                        Button("이모지 추가") {
                            showMultiplePicker = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical, 8)

                    if !collectedEmojis.isEmpty {
                        Button("초기화", role: .destructive) {
                            collectedEmojis.removeAll()
                        }
                    }
                } header: {
                    Text("Multiple Mode")
                } footer: {
                    Text("여러 이모지 연속 선택 가능. 완료 버튼으로 dismiss.")
                }

                // ─── SkinTone Normalization ───
                Section {
                    Picker("스킨톤 정규화", selection: $skinToneMode) {
                        Text("없음 (nil)").tag(0)
                        Text("Strip (제거)").tag(1)
                        Text("Dark (🏿)").tag(2)
                    }

                    HStack {
                        Text(configEmoji)
                            .font(.system(size: 64))
                        Spacer()
                        Button("이모지 선택") {
                            showConfigPicker = true
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Configuration Test")
                } footer: {
                    Text("스킨톤이 있는 이모지를 선택하면 정규화가 적용됩니다.")
                }
            }
            .navigationTitle("EmojiPickerKit")
            // ─── Modifiers ───
            .emojiKeyboard(isPresented: $showSinglePicker, mode: .single) { emoji in
                selectedEmoji = emoji
            }
            .emojiKeyboard(isPresented: $showMultiplePicker, mode: .multiple()) { emoji in
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
        case 2: .dark
        default: nil
        }
        return EmojiKeyboardConfiguration(normalizeSkinTone: normalization)
    }
}

#Preview {
    ContentView()
}
