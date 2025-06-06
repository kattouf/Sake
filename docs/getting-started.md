---
outline: deep
---

# Getting Started

::: tip Alternative Tutorial Format
If you prefer a more detailed, article-style introduction to Sake, you can check out these comprehensive tutorials that walk through practical examples:

- [**Sake Part I: Swift-powered Command Management**](https://swifttoolkit.dev/posts/sake-1) - Covers installation, setup, and creating practical formatting/linting commands
- [**Sake Part II: Advanced Usage**](https://swifttoolkit.dev/posts/sake-2) - Explores command groups, testing automation, and GitHub release management

These articles provide step-by-step guidance with real-world examples and are perfect for getting familiar with Sake's capabilities.
:::

To start using Sake, follow these steps:

### Initialize a new SakeApp

**SakeApp** is a Swift package executable with the `Sake` library integrated, allowing you to define and manage commands.

To generate a new **SakeApp** project template in the current directory, run the following command:

```bash
sake init
```

This will create a new project structure in the `./SakeApp` directory with a basic `Sakefile.swift` containing a simple command.

### Inspect the generated `Sakefile.swift`

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

In this file, `Commands` serves as the entry point of the **SakeApp** executable and acts as the main command group that includes the `hello` command.

### Run your first command

To execute the hello command, you can run:

```bash
sake run hello
```

or simply:

```bash
sake hello
```

This will print "Hello, world!" in your terminal.

### Listing commands

To see all available user-defined (`Sakefile.swift`) commands, run:

```bash
sake list
```

To see all available `sake` commands, run:

```bash
sake --help
```
