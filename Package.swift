// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SovereignShell-SwiftUI",
    platforms: [
        .iOS(.v17),
        .macOS(.v11)
    ],
    products: [
        .executable(
            name: "SovereignShell-SwiftUI",
            targets: ["SovereignShell-SwiftUI"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/google/generative-ai-swift",
            from: "0.5.0"
        ),
        .package(
            url: "https://github.com/apple/swift-nio-ssh",
            from: "0.8.0"
        )
    ],
    targets: [
        .executableTarget(
            name: "SovereignShell-SwiftUI",
            dependencies: [
                .product(name: "GoogleGenerativeAI", package: "generative-ai-swift"),
                .product(name: "NIOSSH", package: "swift-nio-ssh")
            ],
            path: "Sources/SovereignShell-SwiftUI"
        )
    ]
)
