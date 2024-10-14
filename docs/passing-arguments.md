---
outline: deep
---

# Passing Arguments

In Sake, commands can accept arguments, allowing you to customize their behavior based on user input. Below are examples that demonstrate how to pass arguments to commands and how Sake handles them. For advanced argument parsing, refer to [Advanced Argument Parsing](/advanced-argument-parsing).

### Basic Example

In the following basic example, a command called `helloArg` prints a greeting. If a name is provided as an argument, it will greet that name; otherwise, it will default to "Hello, world!":

```swift
public static var helloArg: Command {
    Command(
        description: "Say hello",
        run: { context in
            if let name = context.arguments.first {
                print("Hello, \(name)!")
            } else {
                print("Hello, world!")
            }
        }
    )
}
```

You can execute this command with:

```bash
sake helloArg stranger
```

In this case, the output will be:

```
Hello, stranger!
```

### Example with Sake Arguments

Sake also allows you to pass arguments to both Sake itself and to individual commands. Sake will first parse its own arguments and then pass any remaining arguments to the command.

For example:

```bash
sake --config-path /path/to/config helloArg friend
```

In this example:
- `--config-path /path/to/config` is an argument for Sake itself, specifying a configuration file.
- `friend` is an argument passed to the `helloArg` command, resulting in the output:

```
Hello, friend!
```

::: warning

Watch out for argument collisions. Sake first parses its own arguments, like configuration or environment settings, and then passes any unrecognized arguments to the command. If arguments overlap between Sake and the command, it may cause unexpected behavior. To avoid this, use unique argument names.

:::
