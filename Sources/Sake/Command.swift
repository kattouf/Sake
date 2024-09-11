public extension Command {
    struct Context {
        public let arguments: [String]
        public let environment: [String: String]

        public init(arguments: [String], environment: [String: String]) {
            self.arguments = arguments
            self.environment = environment
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
