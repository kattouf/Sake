# 🍶Sake

[![Latest Release](https://img.shields.io/github/release/kattouf/Sake.svg)](https://github.com/kattouf/Sake/releases/latest)
![](https://github.com/kattouf/Sake/actions/workflows/checks.yml/badge.svg?branch=main)

A Swift-based utility for managing project commands, inspired by Make.

``` swift
struct Commands: SakeApp {
    public static var hello: Command {
        Command(
            run: { context in
                print("Hello, world!")
            }
        )
    }
}
```

``` sh
❯ sake hello
Hello, world!
```

> **⚠️ Note:** Sake is under active development, with ongoing updates and improvements. Use with caution in production environments.

[Full Documentation](https://sakeswift.org) • [Getting Started](#getting-started)

## Features

- **Command Dependencies**: Define commands that depend on other commands, allowing for clear and organized workflows.
- **Conditional Execution**: Set conditions under which a command will or will not be executed.
- **Command Listing**: Easily list all available commands in your SakeApp project.
- **Command Grouping**: Organize commands into groups for better structure and maintainability.
- **Swift-based Configuration**: Use Swift to define and manage your commands, ensuring type safety and flexibility.

## Who It's For?

Sake is designed for Swift developers who prefer to stay within the Swift ecosystem for managing command execution, rather than switching to shell scripting or using tools like Make. By leveraging Swift, Sake ensures type safety, readability, and maintainability in defining commands, making it an intuitive solution for automating project tasks.

## Getting Started

To start using Sake, follow these steps:

1. **Install Sake**
   ```bash
   brew install kattouf/sake/sake
   ```
   Other methods [here](https://sakeswift.org/installation.html)

2. **Initialize a new SakeApp:**

   Run the following command to generate a new SakeApp template in the current directory:

   ```bash
   sake init
   ```

   This will create a new project structure in the `SakeApp` directory with a basic `Sakefile.swift` containing a simple command.

3. **Inspect the generated `Sakefile.swift`:**

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

4. **Run your first command:**

   To execute the `hello` command, run:

   ```bash
   sake hello
   ```

   This will print `Hello, world!` in your terminal.

## Full Documentation

See full documentation at [sakeswift.org](https://sakeswift.org/).

## Contributing

I’m open to suggestions and would be happy to receive any reports, questions, or pull requests. Feel free to contribute by opening issues or submitting pull requests to help improve Sake!

## License

Sake is released under the MIT License. See the [LICENSE](./LICENSE) file for more details.
