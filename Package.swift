// swift-tools-version: 6.1
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
        .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "0.1.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.1"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "6.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "SakeCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .target(name: "SakeCLILibrary"),
                .target(name: "SakeShared"),
            ],
        ),
        .target(
            name: "SakeCLILibrary",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Subprocess", package: "swift-subprocess"),
                .product(name: "Yams", package: "Yams"),
                .target(name: "SakeShared"),
            ],
        ),
        .testTarget(
            name: "SakeCLILibraryTests",
            dependencies: [
                "SakeCLILibrary",
            ],
        ),
        .target(
            name: "Sake",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .target(name: "SakeMacros"),
                .target(name: "SakeShared"),
            ],

        ),
        .testTarget(
            name: "SakeTests",
            dependencies: [
                .target(name: "Sake"),
            ],
        ),
        .target(
            name: "SakeShared",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],

        ),
        .macro(
            name: "SakeMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
        ),
        .testTarget(
            name: "SakeMacrosTests",
            dependencies: [
                .target(name: "SakeMacros"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
        ),
        .testTarget(
            name: "IntegrationTests",
            dependencies: [
                .product(name: "Subprocess", package: "swift-subprocess"),
                .target(name: "SakeShared"),
            ],
        ),
    ],
)
