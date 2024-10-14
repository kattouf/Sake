# How It Works

Sake is composed of two main parts: **sake** and **SakeApp**.

- **sake**: This is the command-line utility that you invoke in your terminal. It is responsible for compiling and executing your Sake commands (as part of SakeApp).
- **SakeApp**: This is a Swift Package Manager (SPM) package that contains all the user-defined commands. When you initialize a new Sake project, SakeApp is created. Its task is to get commands from the user and provide easy access to them (by parsing them with the `@CommandGroup` macro) for `sake`.

### Workflow

When you run a command using `sake`, the following steps occur:

1. **Initialization**: `sake` locates the SakeApp directory and checks for the presence of user-defined commands.
2. **Compilation**: `sake` compiles the SakeApp package to generate an executable that contains all the user-defined commands.
3. **Execution**: Once compiled, `sake` executes the specified command from SakeApp.
