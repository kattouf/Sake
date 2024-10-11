# Run Context

Sake provides a `Command.Context` structure that is used to provide runtime information to commands. This structure contains important details that commands can use during their execution.

### Properties

- **`arguments`**: The arguments passed to the command as an array of strings.
- **`environment`**: A dictionary representing the environment variables available during the command's execution.
- **`appDirectory`**: The path to the SakeApp directory.
- **`runDirectory`**: The directory from which the command was run.

### Using in Commands

The `Context` is passed to the `run` and `skipIf` blocks of a command to provide all the necessary runtime information.

Here's a simple example of using `Context` in a command:

```swift
Command(
    description: "Print arguments",
    skipIf: { context in
        context.arguments.isEmpty
    },
    run: { context in
        print("Arguments: \(context.arguments)")
    }
)
```

In this example, the `skipIf` block checks if there are no arguments, and if so, skips the command. Otherwise, the `run` block prints the arguments provided by the user when the command is executed.
