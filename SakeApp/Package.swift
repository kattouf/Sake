// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "SakeApp",
    platforms: [.macOS(.v10_15)], // Required by SwiftSyntax for the macro feature in Sake
    products: [
        .executable(name: "SakeApp", targets: ["SakeApp"]),
        
    ],
    dependencies: [
        .package(url: "https://github.com/kattouf/Sake", branch: "main"),
        .package(url: "https://github.com/kareman/SwiftShell", from: "5.1.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "SakeApp",
            dependencies: [
                "Sake",
                "SwiftShell"
            ],
            path: "."
        ),
    ]
)
