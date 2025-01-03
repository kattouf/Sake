# 🍶 Sake

[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkattouf%2FSake%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/kattouf/Sake)
[![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkattouf%2FSake%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/kattouf/Sake)
[![Latest Release](https://img.shields.io/github/release/kattouf/Sake.svg)](https://github.com/kattouf/Sake/releases/latest)
![Build Status](https://github.com/kattouf/Sake/actions/workflows/checks.yml/badge.svg?branch=main)

Swift-based utility for managing project commands, inspired by Make. Write your project commands in Swift and enjoy type safety, code reuse, and seamless integration.

``` swift
struct Commands: SakeApp {
    public static var sayHello: Command {
        Command(
            run: { context in
                let name = context.arguments.first ?? "World"
                print("Hello, \(name)!")
            }
        )
    }
}
```

``` sh
❯ sake sayHello Stranger
Hello, Stranger!
```

> [!IMPORTANT]
> Sake is under active development, with ongoing updates and improvements. Use with caution in production environments.

[📚 Documentation](https://sakeswift.org) • [🚀 Getting Started](#-getting-started) • [💻 GitHub](https://github.com/kattouf/Sake)

## ⭐️ Key Features

- **Type-Safe Commands**: Write commands in Swift with full IDE support and compile-time checks
- **Command Dependencies**: Define commands that depend on other commands
- **Conditional Execution**: Skip commands based on custom conditions
- **Command Groups**: Organize commands into logical groups
- **Shell Completion**: Tab completion for all commands
- **Extensible**: Use any Swift package to enhance your commands

## 📚 Getting Started

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
- **Documentation**: Keep your project documentation up to date

## 🤝 Contributing

We welcome contributions! Whether it's:
- 🐛 Bug Reports
- 💡 Feature Requests
- 📖 Documentation Improvements
- 🔧 Code Contributions

Check out our [Contribution Guide](https://sakeswift.org/contribution-guide.html) to get started.

## 📜 License

Sake is released under the MIT License. See the [LICENSE](./LICENSE) file for details.
