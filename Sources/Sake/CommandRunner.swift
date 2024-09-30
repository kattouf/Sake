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
        for command in command.dependencies {
            let runner = CommandRunner(command: command, context: context)
            try await runner.run()
        }
        try await command.run(context)
    }
}
