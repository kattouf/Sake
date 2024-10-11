---
outline: deep
---

# Getting Started

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

To execute the `hello` command, run:

```bash
sake hello
```

This will print "Hello, world!" in your terminal.

### Other commands

To see all available user-defined (`Sakefile.swift`) commands, run:

```bash
sake list
```

To see all available `sake` commands, run:
```bash
sake --help
```
