# Grouping

Sake allows you to organize commands into groups for better structure and maintainability. This is especially useful when you have multiple related commands that need to be organized logically.

To create command groups, use the `@CommandGroup` attribute for each structure. All command groups are listed in the main structure that conforms to the `SakeApp` protocol. Here is an example:

```swift
// Sakefile.swift
import Foundation
import Sake

@main
@CommandGroup
struct Commands: SakeApp {
    static let configuration = SakeAppConfiguration(
        commandGroups: [BuildCommands.self, TestCommands.self]  // List all command groups here
    )
}

// BuildCommands.swift
@CommandGroup
struct BuildCommands {
    public static var build: Command {
        Command(
            description: "Build the project",
            run: { _ in
                print("Building the project...")
            }
        )
    }
}

// TestCommands.swift
@CommandGroup
struct TestCommands {
    public static var test: Command {
        Command(
            description: "Run tests",
            run: { _ in
                print("Running tests...")
            }
        )
    }
}
```

In this example, commands are divided into `BuildCommands` and `TestCommands`. Each group is marked with `@CommandGroup`, and they are all referenced in the main `Commands` structure, which conforms to `SakeApp`.

::: tip

Grouping commands with @CommandGroup and listing them in the main Commands structure is only necessary if you want these commands to be visible and accessible from the terminal. If you have internal commands that should not be accessible via the terminal, you can keep them private and avoid adding them to a command group or marking them with @CommandGroup.

:::

Once grouped, commands can be executed as usual using Sake:

```bash
sake build
sake test
```
