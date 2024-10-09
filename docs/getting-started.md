---
outline: deep
---

# Getting Started

To start using Sake, follow these steps:

### Initialize a new SakeApp

Run the following command to generate a new SakeApp template in the current directory:

```bash
sake init
```

This will create a new project structure in the `SakeApp` directory with a basic `Sakefile.swift` containing a simple command.

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

This command prints "Hello, world!" to the console.

### Run your first command

To execute the `hello` command, run:

```bash
sake hello
```

This will print "Hello, world!" in your terminal.
