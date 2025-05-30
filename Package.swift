// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Sake",
    platforms: [.macOS(.v13)], // required by swift-subprocess
    products: [
        .executable(name: "sake", targets: ["SakeCLI"]),
        .library(name: "Sake", targets: ["Sake"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/swiftlang/swift-subprocess.git", branch: "main"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.0"),
        .package(url: "https://github.com/kareman/SwiftShell", from: "5.1.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "6.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "SakeCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Subprocess", package: "swift-subprocess"),
                .product(name: "SwiftShell", package: "SwiftShell"),
                .product(name: "Yams", package: "Yams"),
                "SakeShared",
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]

        ),
        .testTarget(
            name: "SakeCLITests",
            dependencies: [
                "SakeCLI",
            ]
        ),
        .target(
            name: "Sake",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "SakeMacros",
                "SakeShared",
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]

        ),
        .testTarget(
            name: "SakeTests",
            dependencies: [
                "Sake",
            ]
        ),
        .target(
            name: "SakeShared",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]

        ),
        .macro(
            name: "SakeMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .testTarget(
            name: "SakeMacrosTests",
            dependencies: [
                "SakeMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "IntegrationTests",
            dependencies: [
                "SwiftShell",
                "SakeShared",
            ]
        ),
    ]
)

#if compiler(>=6.0)
    package.targets = package.targets.filter { $0.name != "SakeCLITests" }
#endif
