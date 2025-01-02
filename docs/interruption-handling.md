---
outline: deep
---

# Interruption Handling

Sake provides a mechanism to handle interruptions during command execution using the `InterruptionHandler` in the `Command.Context`. An interruption typically refers to signals like `SIGINT`, which can be triggered by actions such as pressing `Ctrl+C` in the terminal. This feature allows you to register cleanup tasks or other actions that should be executed when a command is interrupted.

## How It Works

The `InterruptionHandler` is part of the `Command.Context` and provides methods to register handlers that will be called if the command is interrupted. This is useful for ensuring that resources are properly released or that certain actions are taken when a command does not complete as expected.

### Generic Solution Using Closures

You can register a closure to be executed when a command is interrupted. This allows you to define custom cleanup logic that will run if the command is interrupted.

#### Example

Here's an example demonstrating how to use a closure with the `InterruptionHandler`:

```swift
public static var exampleCommand: Command {
    Command(
        run: { context in
            context.interruptionHandler.register {
                print("Command was interrupted. Performing cleanup...")
                // Add cleanup code here
            }
            
            // Simulate long-running task
            for i in 1...10 {
                print("Running step \(i)")
                sleep(1) // Simulate work
            }
        }
    )
}
```

### SwiftShell Integration

If you are using the `SwiftShell` library, the `InterruptionHandler` provides additional methods to handle interruptions for asynchronous shell commands. This allows you to register `SwiftShell` commands to be interrupted sequentially.

#### Example

Here's how you can modify the previous example to use the `InterruptionHandler` with `SwiftShell`:

```swift
import Sake
import SwiftShell

public static var exampleCommand: Command {
    Command(
        run: { context in
            let asyncCommand = runAsyncAndPrint(bash: "for i in {1..10}; do echo Running step $i; sleep 1; done")
            context.interruptionHandler.register(asyncCommand)
            try asyncCommand.finish()
        }
    )
}
```

In this example, the `runAsyncAndPrint` function is used to execute a shell command asynchronously. The `asyncCommand` is then registered with the `interruptionHandler`. If the command is interrupted, the registered `SwiftShell` command will be interrupted as well.

## Benefits

- **Resource Management**: Ensure that resources are released properly even if a command is interrupted.
- **Graceful Shutdown**: Perform necessary actions to gracefully shut down or rollback operations.
- **Robustness**: Improve the robustness of your commands by handling unexpected interruptions.

By leveraging the `InterruptionHandler`, you can make your SakeApp commands more resilient and reliable, ensuring that they handle interruptions gracefully and maintain the integrity of your operations. 