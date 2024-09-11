final class CommandRunner {
    private let command: Command
    private let context: Command.Context

    init(command: Command, context: Command.Context) {
        self.command = command
        self.context = context
    }

    func run() throws {
        if try command.skipIf(context) {
            return
        }
        try command.dependencies.forEach {
            let runner = CommandRunner(command: $0, context: context)
            try runner.run()
        }
        try command.run(context)
    }
}
