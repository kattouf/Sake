---
outline: deep
---

# Run Context

Sake provides a `Command.Context` structure that is used to provide runtime information to commands. This structure contains important details that commands can use during their execution.

### Properties

- **`arguments`**: The arguments passed to the command as an array of strings.
- **`environment`**: A dictionary representing the environment variables available during the command's execution.
- **`appDirectory`**: The path to the SakeApp directory.
- **`runDirectory`**: The directory from which the command was run.
- **`storage`**: A storage container used to share data between commands.

### Using in Commands

The `Context` is passed to the `run` and `skipIf` blocks of a command to provide all the necessary runtime information.

Here's an example of using `Context` in a command:

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

In this example:

- The `skipIf` block checks if there are no arguments. If no arguments are provided, the command is skipped.
- The `run` block executes the main logic, which in this case is printing the arguments provided by the user.

### Sharing Data Between Commands

The `storage` property enables sharing data between different command blocks like `run` and `skipIf`, as well as across commands that have dependencies.

Here's an example of using `storage` to share data between a command and its dependency:

```swift
public static var commandA: Command {
    Command(
        run: { context in
            context.storage["command-a-data"] = "jepa"
            print("Command A running")
        }
    )
}

public static var commandB: Command {
    Command(
        dependencies: [commandA], // commandA runs before commandB
        run: { context in
            let commandAData = context.storage["command-a-data"] as? String
            // commandAData == "jepa"
            print("Command B running")
        }
    )
}
```

In this example, `commandA` stores a value in the `context.storage`, which `commandB` then retrieves when it runs. This allows for flexible data sharing and coordination between dependent commands.

### Modifying

Sake provides a way to modify (`map`) the `arguments` and `environment` properties of the `Context` before executing a command. This feature can be particularly useful when working with command dependencies, allowing for customization of their behavior.

Here's an example of using mapping with a command dependency:

```swift
public static var mainCommand: Command {
    Command(
        description: "Main command with dependency",
        dependencies: [dependencyCommand.mapArguments { arguments in
            var modifiedArguments = arguments
            modifiedArguments.append("--dependency-specific-flag")
            return modifiedArguments
        }],
        run: { context in
            print("Running main command...")
        }
    )
}

public static var dependencyCommand: Command {
    Command(
        description: "Dependency command",
        run: { context in
            print("Arguments for dependency: \(context.arguments)")
        }
    )
}
```

In this example:

- The `mainCommand` depends on `dependencyCommand`.
- The `mapArguments` function is used to modify the arguments passed to the `dependencyCommand` by adding a specific flag (`--dependency-specific-flag`).
- This ensures that the dependency command receives customized arguments when executed as part of `mainCommand`.
