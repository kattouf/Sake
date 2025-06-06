public extension Command {
    /// Returns a new `Command` with transformed arguments using the provided closure.
    ///
    /// This method applies the given transformation to the arguments within the command's context.
    /// The transformation is applied both to the current command and recursively to its dependencies.
    ///
    /// - Parameter transform: A closure that transforms the command's arguments.
    /// - Returns: A new `Command` with the transformed arguments.
    func mapArguments(_ transform: @escaping @Sendable ([String]) throws -> [String]) -> Command {
        mapContext { context in
            try context.mapArguments(transform)
        }
    }

    /// Returns a new `Command` with a transformed environment using the provided closure.
    ///
    /// This method applies the given transformation to the environment variables within the command's context.
    /// The transformation is applied both to the current command and recursively to its dependencies.
    ///
    /// - Parameter transform: A closure that transforms the command's environment.
    /// - Returns: A new `Command` with the transformed environment.
    func mapEnvironment(_ transform: @escaping @Sendable ([String: String]) throws -> [String: String]) -> Command {
        mapContext { context in
            try context.mapEnvironment(transform)
        }
    }

    /// Returns a new `Command` with a transformed context using the provided closure.
    ///
    /// This method applies the given transformation to the command's context and its dependencies.
    /// The transformation affects both the `skipIf` and `run` closures.
    ///
    /// - Parameter transform: A closure that transforms the `Context` of the command.
    /// - Returns: A new `Command` with the transformed context.
    private func mapContext(_ transform: @escaping @Sendable (Context) throws -> Context) -> Command {
        Command(
            description: description,
            dependencies: dependencies.map { $0.mapContext(transform) },
            skipIf: { context in
                try await skipIf(transform(context))
            },
            run: { context in
                try await run(transform(context))
            },
        )
    }
}

public extension Command.Context {
    /// Returns a new `Context` with transformed arguments using the provided closure.
    ///
    /// This method applies the given transformation to the arguments in the context while keeping
    /// other properties (environment, appDirectory, runDirectory) unchanged.
    ///
    /// - Parameter transform: A closure that transforms the context's arguments.
    /// - Returns: A new `Context` with the transformed arguments.
    /// - Throws: An error if the transformation fails.
    func mapArguments(_ transform: ([String]) throws -> [String]) throws -> Command.Context {
        try Command.Context(
            arguments: transform(arguments),
            environment: environment,
            appDirectory: appDirectory,
            runDirectory: runDirectory,
            storage: storage,
            interruptionHandler: interruptionHandler,
        )
    }

    /// Returns a new `Context` with a transformed environment using the provided closure.
    ///
    /// This method applies the given transformation to the environment variables in the context while keeping
    /// other properties (arguments, appDirectory, runDirectory) unchanged.
    ///
    /// - Parameter transform: A closure that transforms the context's environment.
    /// - Returns: A new `Context` with the transformed environment.
    /// - Throws: An error if the transformation fails.
    func mapEnvironment(_ transform: ([String: String]) throws -> [String: String]) throws -> Command.Context {
        try Command.Context(
            arguments: arguments,
            environment: transform(environment),
            appDirectory: appDirectory,
            runDirectory: runDirectory,
            storage: storage,
            interruptionHandler: interruptionHandler,
        )
    }
}
