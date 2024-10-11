# Grouping

Sake allows you to organize commands into groups for better structure and maintainability. This is especially useful when you have multiple related commands and want to keep them organized in logical groupings.

You can define command groups by using the `@CommandGroup` attribute for each structure. All command groups should be listed in the main structure that conforms to the `SakeApp` protocol. For example:

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
        Command(description: "Build the project") { _ in
            print("Building the project...")
        }
    }
}

// TestCommands.swift
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
