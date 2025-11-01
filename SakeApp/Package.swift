// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "SakeApp",
    platforms: [.macOS(.v13)], // Required by swift-subprocess
    products: [
        .executable(name: "SakeApp", targets: ["SakeApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kattouf/Sake.git", branch: "main"),
        .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "0.2.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.8.0"),
    ],
    targets: [
        .executableTarget(
            name: "SakeApp",
            dependencies: [
                .product(name: "Sake", package: "Sake"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Subprocess", package: "swift-subprocess"),
                .product(name: "Crypto", package: "swift-crypto"),
            ],
            path: ".",
        ),
    ],
)
