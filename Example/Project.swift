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
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": .dictionary([:]),
                "UIRequiredDeviceCapabilities": .array([.string("arm64")]),
            ]),
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "EmojiPickerKit"),
            ]
        ),
    ],
    schemes: [
        .scheme(
            name: "EmojiPickerExample",
            shared: true,
            buildAction: .buildAction(targets: ["EmojiPickerExample"]),
            runAction: .runAction(
                configuration: .debug,
                arguments: .arguments(
                    environmentVariables: ["OS_ACTIVITY_MODE": "disable"]
                )
            )
        ),
    ]
)
