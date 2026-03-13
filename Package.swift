// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SovereignShell-SwiftUI",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "SovereignShell-SwiftUI",
            targets: ["SovereignShell-SwiftUI"]
        )
    ],
    targets: [
        .executableTarget(
            name: "SovereignShell-SwiftUI",
            path: "Sources/SovereignShell-SwiftUI"
        ),
        .testTarget(
            name: "SovereignShellTests",
            dependencies: ["SovereignShell-SwiftUI"],
            path: "Tests/SovereignShellTests"
        )
    ]
)
