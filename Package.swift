// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Sake",
    platforms: [.macOS(.v10_15)], // required by SwiftSyntax
    products: [
        .executable(name: "SakeCLI", targets: ["SakeCLI"]), // Swift 6.0 produces a error for test builds if the name is "sake"
        .library(name: "Sake", targets: ["Sake"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kareman/SwiftShell", from: "5.1.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-syntax", from: "509.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.1.3"),
    ],
    targets: [
        .executableTarget(
            name: "SakeCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "SwiftShell",
                "SakeShared",
                "Yams",
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
            ]
        ),
        .macro(
            name: "SakeMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
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
