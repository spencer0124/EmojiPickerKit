# EmojiPickerKit

> **Experimental** — This library is in early development. APIs may change without notice between releases. Use at your own risk in production.

A lightweight Swift package that presents the **system emoji keyboard** as a picker for iOS apps. Works with both SwiftUI and UIKit.

## Requirements

- iOS 16.0+
- Swift 5.9+

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/spencer0124/EmojiPickerKit.git", from: "0.1.0")
]
```

Or in Xcode: **File > Add Package Dependencies** and paste the repository URL.

## Quick Start

### SwiftUI

```swift
import EmojiPickerKit

struct ContentView: View {
    @State private var showPicker = false
    @State private var emoji = "😊"

    var body: some View {
        VStack {
            Text(emoji).font(.system(size: 64))
            Button("Pick Emoji") { showPicker = true }
        }
        .emojiKeyboard(isPresented: $showPicker) { selected in
            emoji = selected
        }
    }
}
```

### UIKit

```swift
import EmojiPickerKit

let textField = EmojiKeyboardTextField(mode: .single)
view.addSubview(textField)

textField.onEmojiSelected = { emoji in
    print("Selected: \(emoji)")
}

textField.present()
```

## API Reference

### `.emojiKeyboard()` View Modifier

```swift
func emojiKeyboard(
    isPresented: Binding<Bool>,
    mode: EmojiKeyboardMode = .single,
    config: EmojiKeyboardConfiguration = .default,
    onEmojiSelected: @escaping (String) -> Void
) -> some View
```

| Parameter | Description |
|---|---|
| `isPresented` | Binding that controls keyboard visibility. |
| `mode` | `.single` (auto-dismiss) or `.multiple()` (stays open). |
| `config` | Keyboard configuration (filtering, skin tone, haptics). |
| `onEmojiSelected` | Called with the selected emoji string. |

### `EmojiKeyboardMode`

```swift
enum EmojiKeyboardMode {
    case single
    case multiple(accessoryView: ((_ dismiss: @escaping () -> Void) -> AnyView)? = nil)
}
```

- **`.single`** — Dismisses after one emoji is selected (Reminders-style).
- **`.multiple()`** — Stays open for continuous selection. Shows a default "Done" toolbar, or pass a custom accessory view.

**Custom accessory view example:**

```swift
.emojiKeyboard(
    isPresented: $showPicker,
    mode: .multiple(accessoryView: { dismiss in
        AnyView(Button("Close") { dismiss() })
    })
) { emoji in
    emojis.append(emoji)
}
```

### `EmojiKeyboardConfiguration`

```swift
struct EmojiKeyboardConfiguration {
    var emojiOnly: Bool              // default: true
    var normalizeSkinTone: EmojiSkinToneNormalization?  // default: nil
    var hapticFeedback: UIImpactFeedbackGenerator.FeedbackStyle?  // default: .light
    var disableDictation: Bool       // default: false
}
```

| Option | Default | Description |
|---|---|---|
| `emojiOnly` | `true` | Rejects non-emoji input. |
| `normalizeSkinTone` | `nil` | Normalize skin tone modifiers (see below). |
| `hapticFeedback` | `.light` | Haptic style on selection, or `nil` to disable. |
| `disableDictation` | `false` | Disable dictation button. |

### `EmojiSkinToneNormalization`

Controls how skin tone modifiers are handled on selected emoji.

```swift
enum EmojiSkinToneNormalization {
    case strip        // Remove skin tone → 👋🏽 becomes 👋
    case light        // 🏻
    case mediumLight  // 🏼
    case medium       // 🏽
    case mediumDark   // 🏾
    case dark         // 🏿
}
```

```swift
let config = EmojiKeyboardConfiguration(normalizeSkinTone: .strip)
// User selects 👋🏽 → callback receives 👋
```

### `EmojiKeyboardTextField` (UIKit)

```swift
class EmojiKeyboardTextField: UITextField {
    init(mode: EmojiKeyboardMode = .single,
         config: EmojiKeyboardConfiguration = .default)

    var config: EmojiKeyboardConfiguration
    var onEmojiSelected: ((String) -> Void)?

    func present()   // Show the emoji keyboard
    func dismiss()   // Hide the emoji keyboard
}
```

### String Extensions

```swift
"😊".isSingleEmoji   // true
"👨‍👩‍👧‍👦".isSingleEmoji  // true (ZWJ sequence = one glyph)
"hi".isSingleEmoji   // false
"😊😊".isSingleEmoji // false

"hello 😊".isEmoji   // false
"😊🔥".isEmoji       // true

"👋🏽".normalizingSkinTone(to: .strip)  // "👋"
"👋🏽".normalizingSkinTone(to: .dark)   // "👋🏿"
```

## Contributing

Contributions are welcome! Here's how to get started:

1. **Fork** the repository and clone your fork.
2. Create a feature branch: `git checkout -b feature/my-change`
3. Make your changes and add tests.
4. Run the test suite:
   ```bash
   xcodebuild test \
     -scheme EmojiPickerKit \
     -sdk iphonesimulator \
     -destination "platform=iOS Simulator,name=iPhone 16 Pro"
   ```
5. Open a pull request with a clear description.

### Project Structure

```
Sources/EmojiPickerKit/
├── EmojiKeyboardTextField.swift      # Core UITextField subclass
├── EmojiKeyboardModifier.swift       # SwiftUI wrapper + view modifier
├── EmojiKeyboardConfiguration.swift  # Configuration struct
└── Extensions/
    ├── String+Emoji.swift            # isEmoji, isSingleEmoji
    └── String+SkinTone.swift         # Skin tone normalization

Example/                              # Demo app (Tuist project)
Tests/EmojiPickerKitTests/            # Test suite
```

### Guidelines

- Keep PRs focused — one feature or fix per PR.
- Follow existing code style and naming conventions.
- Add tests for new public API surface.
- This project uses no external dependencies — please keep it that way.
