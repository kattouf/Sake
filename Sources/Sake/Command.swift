public extension Command {
    struct Context {
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

public struct Command {
    public let description: String?
    public let dependencies: [Command]
    public let skipIf: (Context) throws -> Bool
    public let run: (Context) throws -> Void

    public init(
        description: String? = nil,
        dependencies: [Command] = [],
        skipIf: @escaping (Context) throws -> Bool = { _ in false },
        run: @escaping (Context) throws -> Void = { _ in }
    ) {
        self.description = description
        self.dependencies = dependencies
        self.skipIf = skipIf
        self.run = run
    }
}
