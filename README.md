# 🍶 Sake

[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkattouf%2FSake%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/kattouf/Sake)
[![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkattouf%2FSake%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/kattouf/Sake)
[![Latest Release](https://img.shields.io/github/release/kattouf/Sake.svg)](https://github.com/kattouf/Sake/releases/latest)
[![codecov](https://codecov.io/gh/kattouf/Sake/graph/badge.svg?token=TTQYPIKOPN)](https://codecov.io/gh/kattouf/Sake)
![Build Status](https://github.com/kattouf/Sake/actions/workflows/checks.yml/badge.svg?branch=main)

Swift-based utility for managing project commands, inspired by Make. Write your project commands in Swift and enjoy type safety, code reuse, and seamless integration.

## ⭐️ Key Features

- **Swift-Native Workflow**: Write, execute, and manage all your project commands in Swift with full IDE support, type safety, and seamless integration
- **Command Dependencies**: Define commands that depend on other commands
- **Conditional Execution**: Skip commands based on custom conditions
- **Command Listing**: Display all available commands with their descriptions

## 🏃 Less Talk, More Action

First, take a look at what you can accomplish with Sake, and then we'll dive into how to make it happen:

Define your project commands like this:
``` swift
// Sakefile.swift

struct Commands: SakeApp {

    // MARK: - Code style

    public static var format: Command {
        Command(
            description: "Format source code",
            dependencies: [BrewCommands.ensureSwiftFormatInstalled],
            run: { context in
                try runAndPrint("swiftformat", "Sources", "Package.swift")
            }
        )
    }

    // MARK: - Release automation

    public static var buildReleaseArtifacts: Command {
        Command(
            description: "Build release artifacts for distribution",
            dependencies: [buildRelease, stripBinary, createArchive]
        )
    }

    static var buildRelease: Command {
        Command(
            description: "Build optimized release binary",
            run: { context in
                try runAndPrint("swift", "build", "--configuration", "release")
            }
        )
    }

    static var stripBinary: Command {
        Command(
            description: "Strip debug symbols to reduce size",
            run: { context in
                try runAndPrint("strip", "-rSTx", ".build/release/MyApp")
            }
        )
    }

    static var createArchive: Command {
        Command(
            description: "Create distribution ZIP archive",
            run: { context in
                try runAndPrint("zip", "-j", "MyApp.zip", ".build/release/MyApp")
            }
        )
    }
}
```

> [!NOTE]
> The `runAndPrint` function used in this example is not provided by Sake by default. For running CLI commands in your Sake commands, please refer to the [CLI Tools Running documentation](https://sakeswift.org/advanced-cli-tools-running.html).

Then run them like this:
``` sh
❯ sake list
Commands:
 * format - Format source code
 * buildReleaseArtifacts - Build release artifacts for distribution

❯ sake buildReleaseArtifacts
Building for production...
Compiling MyApp...
Build complete.
  creating: MyApp.zip
```

[📚 Documentation](https://sakeswift.org) • [🚀 Getting Started](#-getting-started) • [💻 GitHub](https://github.com/kattouf/Sake)

## 🚀 Getting Started

1. **Install Sake**
   ```bash
   brew install kattouf/sake/sake
   ```
   See [other installation methods](https://sakeswift.org/installation.html)

2. **Initialize a new SakeApp:**
   ```bash
   sake init
   ```

3. **Run your first command:**
   ```bash
   sake hello
   ```

## 📖 Example Use Cases

- **Build Automation**: Compile your project with different configurations and run tests
- **Release Management**: Automate version updates
- **Code Quality**: Run formatters and linters to maintain consistent code style

## 🤝 Contributing

We welcome contributions! Whether it's:
- 🐛 Bug Reports
- 💡 Feature Requests
- 📖 Documentation Improvements
- 🔧 Code Contributions

👋 **Before writing code**: We kindly ask that you open a discussion or issue first to discuss your proposed changes. This helps ensure your time is well-spent on features or fixes that align with the project's direction and prevents duplicate efforts.

Check out our [Contribution Guide](https://sakeswift.org/contribution-guide.html) to find more details on how to get started.

## 📜 License

Sake is released under the MIT License. See the [LICENSE](./LICENSE) file for details.
