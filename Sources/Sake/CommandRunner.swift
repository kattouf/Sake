/// A class responsible for executing a `Command` within a given context.
///
/// The `CommandRunner` handles the execution of a command, including checking if the command
/// should be skipped, running dependencies (either concurrently or sequentially), and finally
/// executing the main command logic.
public final class CommandRunner {
    /// The command to be executed.
    private let command: Command

    /// The context in which the command will be executed.
    private let context: Command.Context

    /// Initializes a new `CommandRunner` for the given command and context.
    ///
    /// - Parameters:
    ///   - command: The `Command` to be executed.
    ///   - context: The `Context` in which the command will be executed.
    public init(command: Command, context: Command.Context) {
        self.command = command
        self.context = context
    }

    /// Executes the command and its dependencies.
    ///
    /// This method first checks if the command should be skipped by evaluating the `skipIf` condition.
    /// If the command is not skipped, it runs any dependencies, either concurrently or sequentially,
    /// based on the `runDependenciesConcurrently` flag. After all dependencies are executed, the main
    /// command logic is run.
    ///
    /// - Throws: An error if either the dependencies or the command itself fail to execute.
    public func run() async throws {
        if try await command.skipIf(context) {
            return
        }

        if command.runDependenciesConcurrently {
            await withThrowingTaskGroup(of: Void.self) { [context] group in
                for command in command.dependencies {
                    group.addTask {
                        let runner = CommandRunner(command: command, context: context)
                        try await runner.run()
                    }
                }
            }
        } else {
            for command in command.dependencies {
                let runner = CommandRunner(command: command, context: context)
                try await runner.run()
            }
        }

        try await command.run(context)
    }
}
