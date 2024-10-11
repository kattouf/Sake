# Argument Parsing

In Sake, you can use additional Swift libraries to enhance the functionality of your commands, including argument parsing. One of the popular libraries for argument parsing in Swift is [`ArgumentParser`](https://github.com/apple/swift-argument-parser).

### Using ArgumentParser

With `ArgumentParser`, you can define custom arguments for your Sake commands, making them more dynamic and user-friendly. Below is an example of how you can integrate `ArgumentParser` into a Sake command to parse command-line arguments:

```swift {12-16}
import ArgumentParser
import Foundation
import Sake

@main
@CommandGroup
struct Commands: SakeApp {
    public static var lint: Command {
        Command(
            description: "Run SwiftLint",
            run: { context in
                struct Arguments: ParsableArguments {
                    @Flag(name: .shortAndLong, help: "Quiet mode")
                    var quiet: Bool = false
                }
                let arguments: Arguments = try Arguments.parse(context.arguments)

                if arguments.quiet {
                    print("Running SwiftLint in quiet mode...")
                } else {
                    print("Running SwiftLint...")
                }
            }
        )
    }
}
```

#### Explanation

1. **Defining Arguments**: The `Arguments` struct conforms to `ParsableArguments`, allowing you to define flags and options. In this example, a flag called `--quiet` (or `-q`) is defined, which the user can pass when running the command.

2. **Parsing Arguments**: The `Arguments.parse(context.arguments)` method is used to parse the command-line arguments provided by the user.

3. **Using Parsed Arguments**: Once parsed, you can use the arguments to modify the command's behavior, such as running a command in quiet mode.

#### Adding Dependencies

To use `ArgumentParser` in your `SakeApp`, you need to add it to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0")
]
```

This makes it easy to parse arguments and enhance the functionality of your commands.
