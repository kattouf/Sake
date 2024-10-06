public extension Command {
    struct Context: Sendable {
        public let arguments: [String]
        public let environment: [String: String]
        public let appDirectory: String
        public let runDirectory: String

        init(arguments: [String], environment: [String: String], appDirectory: String, runDirectory: String) {
            self.arguments = arguments
            self.environment = environment
            self.appDirectory = appDirectory
            self.runDirectory = runDirectory
        }
    }
}

public struct Command: Sendable {
    public let description: String?
    public let dependencies: [Command]
    public let runDependenciesConcurrently: Bool
    public let skipIf: @Sendable (Context) async throws -> Bool
    public let run: @Sendable (Context) async throws -> Void

    public init(
        description: String? = nil,
        dependencies: [Command] = [],
        runDependenciesConcurrently: Bool = false,
        skipIf: @escaping @Sendable (Context) async throws -> Bool = { _ in false },
        run: @escaping @Sendable (Context) async throws -> Void = { _ in }
    ) {
        self.description = description
        self.dependencies = dependencies
        self.runDependenciesConcurrently = runDependenciesConcurrently
        self.skipIf = skipIf
        self.run = run
    }
}
