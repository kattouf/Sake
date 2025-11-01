# CLI Tools Running

In Sake, you can integrate external Swift libraries to run and automate CLI commands as part of your tasks. The recommended library for this purpose is [`swift-subprocess`](https://github.com/swiftlang/swift-subprocess), which provides a modern, Swift-native way to spawn and manage processes.

### Using swift-subprocess for Command Execution

With `swift-subprocess`, you can execute CLI commands directly from within your Sake commands, making it easy to automate various steps in your project workflow.

Here is an example of using `swift-subprocess` to run CLI commands in a Sake command:

```swift {12-17}
import Foundation
import Sake
import Subprocess

@main
@CommandGroup
struct Commands: SakeApp {
    public static var test: Command {
        Command(
            description: "Test the project using a shell command",
            run: { context in
                try await run(
                    .name("swift"),
                    arguments: ["test"],
                    output: .fileDescriptor(.standardOutput, closeAfterSpawningProcess: false),
                    error: .fileDescriptor(.standardError, closeAfterSpawningProcess: false),
                )
            }
        )
    }
}
```

In this example, the `test` command uses `swift-subprocess`'s `run` function to execute the `swift test` command, which runs the project tests and prints the output to the console.

#### Adding Dependencies

To use `swift-subprocess` in your Sake commands, add it to your `SakeApp/Package.swift` file:

```swift{3}
dependencies: [
    .package(url: "https://github.com/kattouf/Sake", from: "1.0.0"),
    .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "0.2.0")
]
```
And then adding the product to `SakeApp` target that needs access to the library:
```swift{6}
targets: [
    .executableTarget(
        name: "SakeApp",
        dependencies: [
            .product(name: "Sake", package: "Sake"),
            .product(name: "Subprocess", package: "swift-subprocess")
        ],
        path: "."
    ),
]
```

This way, you can seamlessly run external commands within your Swift environment and automate tasks effectively.

The flexibility of using external libraries allows you to extend your automation capabilities, making Sake a powerful tool for project command management.
