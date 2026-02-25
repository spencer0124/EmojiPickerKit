// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EmojiPickerKit",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "EmojiPickerKit",
            targets: ["EmojiPickerKit"]
        ),
    ],
    targets: [
        .target(
            name: "EmojiPickerKit",
            path: "Sources/EmojiPickerKit"
        ),
        .testTarget(
            name: "EmojiPickerKitTests",
            dependencies: ["EmojiPickerKit"],
            path: "Tests/EmojiPickerKitTests"
        ),
    ]
)
