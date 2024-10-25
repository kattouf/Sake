/// Represents a command that can be executed in the Sake project.
///
/// Defines a command with dependencies, execution logic, and optional skip conditions.
/// Commands can have dependencies, run them concurrently if needed, and provide logic to
/// conditionally skip execution.
public struct Command: Sendable {
    /// A brief description of the command.
    ///
    /// This optional description provides context on what the command does.
    /// It can be displayed when listing commands or in help outputs.
    public let description: String?

    /// A list of commands that must be executed before this command.
    ///
    /// These dependencies represent tasks or commands that should be completed
    /// prior to running the main logic of the command. Dependencies can either be run
    /// sequentially or concurrently based on the `runDependenciesConcurrently` flag.
    public let dependencies: [Command]

    /// Determines if the dependencies should be run concurrently.
    ///
    /// If set to `true`, the dependencies are executed in parallel. If set to `false`,
    /// they are run sequentially, one after another.
    public let runDependenciesConcurrently: Bool

    /// A closure that determines if the command should be skipped.
    ///
    /// This closure is executed before running the command, allowing for a condition-based
    /// skip. If the closure returns `true`, the command is skipped.
    ///
    /// - Parameter context: The current execution context.
    /// - Throws: An error if the closure fails to execute properly.
    /// - Returns: A boolean indicating whether the command should be skipped.
    public let skipIf: @Sendable (Context) async throws -> Bool

    /// The main logic of the command.
    ///
    /// This closure contains the code that defines what the command does when executed.
    ///
    /// - Parameter context: The current execution context.
    /// - Throws: An error if the command fails to execute properly.
    public let run: @Sendable (Context) async throws -> Void

    /// Initializes a new `Command` with optional dependencies, concurrent execution,
    /// a skip condition, and the command's main logic.
    ///
    /// - Parameters:
    ///   - description: An optional description of the command.
    ///   - dependencies: A list of commands that should be executed before this one.
    ///   - runDependenciesConcurrently: A flag indicating if dependencies should run in parallel.
    ///   - skipIf: A closure that determines whether the command should be skipped.
    ///   - run: A closure that contains the command's logic.
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
