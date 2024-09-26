public final class CommandRunner {
    private let command: Command
    private let context: Command.Context

    public init(command: Command, context: Command.Context) {
        self.command = command
        self.context = context
    }

    public func run() throws {
        if try command.skipIf(context) {
            return
        }
        try command.dependencies.forEach { command in
            let runner = CommandRunner(command: command, context: context)
            try runner.run()
        }
        try command.run(context)
    }
}
