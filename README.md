# 🍶Sake

[![Latest Release](https://img.shields.io/github/release/kattouf/Sake.svg)](https://github.com/kattouf/Sake/releases/latest)
![](https://github.com/kattouf/Sake/actions/workflows/tests.yml/badge.svg?branch=main)

A Swift-based utility for managing command execution with dependencies and conditions, inspired by Make.

``` swift
struct Commands: SakeApp {
    public static var hello: Command {
        Command(
            run: { context in
                print("Hello, world!")
            }
        )
    }
}
```

``` sh
❯ sake hello
Hello, world!
```

> **⚠️ Note:** Sake is still under active development and is not yet production-ready. Use with caution in production environments.

[Installation](#installation) • [Getting Started](#getting-started) • [Commands](#commands) • [Features In Detail](#features-in-detail) • [Configuration](#configuration) • [Advanced Usage](#advanced-usage)

## Features

- **Command Dependencies**: Define commands that depend on other commands, allowing for clear and organized workflows.
- **Conditional Execution**: Set conditions under which a command will or will not be executed.
- **Command Listing**: Easily list all available commands in your SakeApp project.
- **Command Grouping**: Organize commands into groups for better structure and maintainability.
- **Swift-based Configuration**: Use Swift to define and manage your commands, ensuring type safety and flexibility.

## Why Sake?

Sake is designed for Swift developers who prefer to stay within the Swift ecosystem for managing command execution, rather than switching to shell scripting or using tools like Make. By leveraging Swift, Sake ensures type safety, readability, and maintainability in defining commands, making it an intuitive solution for automating project tasks.

## Installation

### Requirements

Currently only macOS is supported and requires **Swift 5.10** **(Xcode 15.3)** or higher.

### [Homebrew](https://brew.sh)

``` sh
brew install kattouf/sake/sake
```

### [Mint](https://github.com/yonaskolb/Mint)

``` sh
mint install kattouf/Sake
```

### [Mise](https://mise.jdx.dev)

``` sh
mise use -g spm:kattouf/Sake
```

### Manual Installation

Download the binary for your platform from the [releases page](https://github.com/kattouf/Sake/releases), and place it in your executable path.

## Getting Started

To start using Sake, follow these steps:

1. **Initialize a new SakeApp:**

   Run the following command to generate a new SakeApp template in the current directory:

   ```bash
   sake init
   ```

   This will create a new project structure in the `SakeApp` directory with a basic `Sakefile.swift` containing a simple command.

2. **Inspect the generated `Sakefile.swift`:**

   Navigate to the `SakeApp` directory and open `Sakefile.swift` to see the pre-defined `hello` command:

   ```swift
   import Foundation
   import Sake

   @main
   @CommandGroup
   struct Commands: SakeApp {
       public static var hello: Command {
           Command(
               run: { _ in
                   print("Hello, world!")
               }
           )
       }
   }
   ```

   This command prints "Hello, world!" to the console.

3. **Run your first command:**

   To execute the `hello` command, run:

   ```bash
   sake hello
   ```

   This will print "Hello, world!" in your terminal.

## Features In Detail

### Declaring Commands

When defining commands in Sake, there are a few important rules to follow:

- **Visibility**: Only `public` commands are visible for execution. This allows you to define internal commands that are not meant to be run directly. By marking some commands as non-public, you can control which commands are exposed for execution.
  
- **Static declaration**: Only `static` commands are supported in Sake. All commands must be declared as `static` within the command group or main structure.

### Command Grouping

Sake allows you to organize commands into groups for better structure and maintainability. This is especially useful when you have multiple related commands and want to keep them organized in logical groupings.

You can define command groups by using the `@CommandGroup` attribute for each structure. All command groups should be listed in the main structure that conforms to the `SakeApp` protocol. For example:

```swift
import Foundation
import Sake

@main
@CommandGroup
struct Commands: SakeApp {
    static let configuration = SakeAppConfiguration(
        commandGroups: [BuildCommands.self, TestCommands.self]  // List all command groups here
    )
}

@CommandGroup
struct BuildCommands {
    public static var build: Command {
        Command(description: "Build the project") { _ in
            print("Building the project...")
        }
    }
}

@CommandGroup
struct TestCommands {
    public static var test: Command {
        Command(description: "Run tests") { _ in
            print("Running tests...")
        }
    }
}
```

In this example, the commands are organized into `BuildCommands` and `TestCommands` groups. Each group is annotated with `@CommandGroup`, and all groups are listed in the main `Commands` structure that conforms to `SakeApp`.

When running Sake, you can execute commands from these groups as usual:

```bash
sake build
sake test
```

### Command Features: `skipIf` and `dependencies`

Sake provides two powerful features for managing command execution: `skipIf` and `dependencies`.

#### `skipIf`

The `skipIf` feature allows you to define conditions under which a command will be skipped. This is useful when you want to avoid running a command in certain scenarios. The `skipIf` closure receives the command context (arguments and environment) and returns `true` if the command should be skipped.

For example:

```swift
Command(
    description: "Deploy the project",
    skipIf: { context in
        // Skip the command if deployment is not needed
        return !shouldDeploy()
    }
) { _ in
    print("Deploying the project...")
}
```

In this example, the `deploy` command will only run if the `shouldDeploy()` function returns `true`.

#### `dependencies`

The `dependencies` feature allows you to define commands that must be run before the main command. Dependencies ensure that any prerequisite commands are executed in the correct order.

For example:

```swift
Command(
    description: "Build the project",
    dependencies: [clean]
) { _ in
    print("Building the project...")
}
```

In this example, the `clean` command will always be executed before the `build` command. This ensures that the project is cleaned before building.

#### Combining `skipIf` and `dependencies`

You can combine both features in a single command to control when the command should run and ensure all dependencies are executed:

```swift
Command(
    description: "Run tests",
    dependencies: [build],
    skipIf: { context in
        return !shouldRunTests()
    }
) { _ in
    print("Running tests...")
}
```

In this example, the `tests` command will only run if `shouldRunTests()` returns `true`, and it will ensure that the `build` command is executed beforehand.

### Command Name Conversions

Sake supports automatic conversion of command names to different case styles. You can specify the conversion strategy via configuration or environment variables.

Available conversion strategies:
- **keepOriginal**: Keeps the original case of the command names.
- **toSnakeCase**: Converts command names to `snake_case`.
- **toKebabCase**: Converts command names to `kebab-case`.

You can configure this in the `.sake.yml` file:

```yaml
case_converting_strategy: toSnakeCase
```

The command name conversion is applied when execute or listing commands.

## Configuration

Sake provides flexible options for configuration, which can be set via:

1. **CLI arguments**: The highest priority, passed directly when running a command.
2. **Environment variables**: Can be set in your system or project environment.
3. **Configuration file (`.sake.yml`)**: Defines default settings for your project.

### Configuration file (.sake.yml)

You can define configuration options in the `.sake.yml` file, located in the root of your project. For example:

```yaml
case_converting_strategy: toSnakeCase
sake_app_path: some/path
```

### Environment variables

Sake also supports configuration via environment variables. The following environment variables are available:

- **`SAKE_CONFIG_PATH`**: Path to the `.sake.yml` file.
- **`SAKE_APP_PATH`**: Path to the SakeApp package.

For example, you can set these variables in your environment:

```bash
export SAKE_CONFIG_PATH="/path/to/.sake.yml"
export SAKE_APP_PATH="/path/to/SakeApp"
```

### Resolution order

Configuration is resolved in the following order:

1. **CLI arguments**: If passed, CLI arguments will override any other settings.
2. **Environment variables**: If CLI arguments are not provided, Sake will check for environment variables.
3. **Configuration file**: If neither CLI arguments nor environment variables are present, Sake will fall back to the `.sake.yml` file.

## Advanced Usage

In Sake, you can use additional Swift libraries to enhance your commands, such as parsing arguments or executing CLI commands. Below is an example of how you can integrate `ArgumentParser` for argument parsing and `SwiftShell` for running CLI commands.

### Example: Argument Parsing and CLI Command Execution

```swift
import ArgumentParser
import Foundation
import Sake
import SwiftShell

@main
@CommandGroup
struct Commands: SakeApp {
    static let configuration = SakeAppConfiguration(
        commandGroups: [BrewCommands.self]
    )

    public static var lint: Command {
        Command(
            description: "Run SwiftLint",
            dependencies: [BrewCommands.ensureSwiftLintInstalled]
        ) { context in
            struct Arguments: ParsableArguments {
                @Flag(name: .shortAndLong, help: "Quite mode")
                var quite: Bool = false
            }
            let arguments: Arguments = try Arguments.parse(context.arguments)

            if arguments.quite {
                try run("swiftlint")
            } else {
                try runAndPrint("swiftlint")
            }
        }
    }
}

@CommandGroup
struct BrewCommands {
    static var ensureSwiftLintInstalled: Command {
        Command(
            skipIf: { _ in
                run("which", "swiftlint").succeeded
            },
            run: { _ in
                print("Installing SwiftLint...")
                try runAndPrint("brew", "install", "swiftlint")
            }
        )
    }
}
```

### Explanation

1. **Argument Parsing**: 
   In the `lint` command, we use `ArgumentParser` to define a flag (`--quite` or `-q`). This flag can be passed by the user when running the command (`sake lint --quite`). We parse the arguments using `Arguments.parse(context.arguments)`.

2. **CLI Command Execution**: 
   We use `SwiftShell` to execute the `swiftlint` command. Depending on whether the `--quite` flag is set, the command is either run silently (`run`) or with output to the console (`runAndPrint`).

### Flexible Configuration

You can easily integrate other tools or libraries into your `SakeApp` by adding them to the `Package.swift` file. In this example, the `ArgumentParser` and `SwiftShell` libraries are used, but you're free to choose the tools you prefer.

For example, to include `ArgumentParser` and `SwiftShell` in your `SakeApp`, add the following dependencies to your `SakeApp/Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    .package(url: "https://github.com/kareman/SwiftShell", from: "5.1.0")
]
```

This setup allows you to flexibly use different libraries and tools in your project, just like in any other Swift package.

## Contributing

I’m open to suggestions and would be happy to receive any reports, questions, or pull requests. Feel free to contribute by opening issues or submitting pull requests to help improve Sake!

## License

Sake is released under the MIT License. See the [LICENSE](./LICENSE) file for more details.
