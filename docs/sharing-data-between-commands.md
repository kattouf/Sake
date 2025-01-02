---
outline: deep
---

# Sharing Data Between Commands

Sake provides a powerful feature that allows commands to share data using the `storage` property of the `Command.Context`. This enables seamless data exchange between different command blocks, such as `run` and `skipIf`, as well as across commands with dependencies.

## How It Works

The `storage` property is a thread-safe container that can store and retrieve data using key-value pairs. This allows commands to communicate and coordinate by sharing necessary information.

### Example

Here's an example demonstrating how to use `storage` to share data between a command and its dependency:

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

### Explanation

- **Command A**: Stores a value in the `context.storage` with the key `"command-a-data"`.
- **Command B**: Retrieves the stored value using the same key and uses it during its execution.

This mechanism allows for flexible data sharing and coordination between dependent commands, enhancing the modularity and reusability of your command logic.

## Benefits

- **Decoupling**: Commands can be designed independently, focusing on their specific tasks while relying on shared data for coordination.
- **Reusability**: Shared data can be reused across multiple commands, reducing redundancy and improving maintainability.
- **Synchronization**: The thread-safe nature of `storage` ensures that data access is synchronized, preventing race conditions.

By leveraging the `storage` property, you can build complex workflows with interdependent commands that communicate effectively, making your SakeApp more robust and efficient. 