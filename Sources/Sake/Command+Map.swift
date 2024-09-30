public extension Command {
    func mapArguments(_ transform: @escaping @Sendable ([String]) throws -> [String]) -> Command {
        mapContext { context in
            try context.mapArguments(transform)
        }
    }

    func mapEnvironment(_ transform: @escaping @Sendable ([String: String]) throws -> [String: String]) -> Command {
        mapContext { context in
            try context.mapEnvironment(transform)
        }
    }

    private func mapContext(_ transform: @escaping @Sendable (Context) throws -> Context) -> Command {
        Command(
            description: description,
            dependencies: dependencies.map { $0.mapContext(transform) },
            skipIf: skipIf,
            run: { context in
                try await run(transform(context))
            }
        )
    }
}

public extension Command.Context {
    func mapArguments(_ transform: ([String]) throws -> [String]) throws -> Command.Context {
        try Command.Context(
            arguments: transform(arguments),
            environment: environment,
            appDirectory: appDirectory,
            runDirectory: runDirectory
        )
    }

    func mapEnvironment(_ transform: ([String: String]) throws -> [String: String]) throws -> Command.Context {
        try Command.Context(
            arguments: arguments,
            environment: transform(environment),
            appDirectory: appDirectory,
            runDirectory: runDirectory
        )
    }
}
