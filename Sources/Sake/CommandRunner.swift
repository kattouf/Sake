public final class CommandRunner {
    private let command: Command
    private let context: Command.Context

    public init(command: Command, context: Command.Context) {
        self.command = command
        self.context = context
    }

    public func run() async throws {
        if try command.skipIf(context) {
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
