# Example: Argument Parsing and CLI Tool Running

The example below demonstrates a linting command that can accept arguments and ensures that SwiftLint is installed if it's not already available.

```swift
import ArgumentParser
import Foundation
import Sake
import SwiftShell

@main
@CommandGroup
struct Commands: SakeApp {

    // Define a lint command that runs SwiftLint with optional quiet mode
    public static var lint: Command {
        Command(
            description: "Run SwiftLint",
            dependencies: [ensureSwiftLintInstalled], // Ensure SwiftLint is installed before linting,
            run: { context in
                struct Arguments: ParsableArguments {
                    @Flag(name: .shortAndLong, help: "Quiet mode")
                    var quiet: Bool = false
                }
                // Parse the command-line arguments
                let arguments: Arguments = try Arguments.parse(context.arguments)

                // Run SwiftLint based on the provided arguments
                if arguments.quiet {
                    run("swiftlint")
                } else {
                    try runAndPrint("swiftlint")
                }
            }
        )
    }

    // Command to ensure SwiftLint is installed before running lint
    // Internal visibility (not available to be run directly from terminal)
    static var ensureSwiftLintInstalled: Command {
        Command(
            skipIf: { _ in
                run("which", "swiftlint").succeeded // Skip installation if SwiftLint is already available
            },
            run: { _ in
                print("Installing SwiftLint...")
                // Install SwiftLint using Homebrew
                try runAndPrint("brew", "install", "swiftlint")
            }
        )
    }
}
```
