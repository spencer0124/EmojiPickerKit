import ProjectDescription

let project = Project(
    name: "EmojiPickerExample",
    targets: [
        .target(
            name: "EmojiPickerExample",
            destinations: .iOS,
            product: .app,
            bundleId: "com.example.emojipickerkit",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "EmojiPickerKit"),
            ]
        ),
    ]
)
