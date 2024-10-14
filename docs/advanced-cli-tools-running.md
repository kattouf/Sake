# CLI Tools Running

In Sake, you can integrate external Swift libraries to run and automate CLI commands as part of your tasks. A popular library for this purpose is [`SwiftShell`](https://github.com/kareman/SwiftShell), which makes running shell commands easy and convenient.

### Using SwiftShell for Command Execution

With `SwiftShell`, you can execute CLI commands directly from within your Sake commands, making it easy to automate various steps in your project workflow.

Here is an example of using `SwiftShell` to run CLI commands in a Sake command:

```swift {12}
import Foundation
import Sake
import SwiftShell

@main
@CommandGroup
struct Commands: SakeApp {
    public static var build: Command {
        Command(
            description: "Build the project using a shell command"
        ) { context in
            try runAndPrint("swift", "build")
        }
    }
}
```

In this example, the `build` command uses `SwiftShell`'s `runAndPrint` function to execute the `swift build` command, which builds the project and prints the output to the console.

#### Adding Dependencies

To use `SwiftShell` in your Sake commands, add it to your `SakeApp/Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/kareman/SwiftShell", from: "5.1.0")
]
```

This way, you can seamlessly run external commands within your Swift environment and automate tasks effectively.

The flexibility of using external libraries allows you to extend your automation capabilities, making Sake a powerful tool for project command management.


