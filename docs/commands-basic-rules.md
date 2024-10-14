# Basic Rules

When defining commands in Sake, there are a few important things to know:

- **Visibility**: Only `public` commands are visible for execution. This allows you to define internal commands that are not meant to be run directly. By marking some commands as non-public, you can control which commands are exposed for execution.
- **Static declaration**: Only `static` commands are supported in Sake. All commands must be declared as `static` within the command group or main structure.
- **Command Type**: Only commands of type `Command` or `Sake.Command` are supported. Typealiases for commands will not work.
