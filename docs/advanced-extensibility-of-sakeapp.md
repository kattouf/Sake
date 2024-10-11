# Extensibility of SakeApp

SakeApp is highly extensible, allowing you to enhance your commands with any Swift libraries that you prefer. Whether you need argument parsing, networking, or interaction with the filesystem, you can integrate external libraries seamlessly.

You can easily integrate libraries by adding them to your `SakeApp/Package.swift` file, just as you would with any Swift Package Manager (SPM) project. For example:

```swift
dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    .package(url: "https://github.com/kareman/SwiftShell", from: "5.1.0")
]
```

This allows you to use libraries like `ArgumentParser` or `SwiftShell` to extend the capabilities of your commands.

This flexibility lets you create commands that suit your specific needs while benefiting from Swift's extensive ecosystem of third-party libraries.
