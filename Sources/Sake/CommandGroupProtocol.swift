/// A macro that marks a type as a command group in the Sake project.
///
/// This macro attaches an extension conforming to `CommandGroup` and generates
/// a `commands` property that holds all the available commands for the group.
///
/// - Note: Command names are initially derived from the variable names, but they can
///   be converted according to the strategy specified in the configuration.
///
/// Usage:
/// ```swift
/// @CommandGroup
/// struct MyCommands {
///     // Define commands here
/// }
/// ```
///
/// The `CommandGroup` macro simplifies the process of grouping and organizing commands.
@attached(extension, conformances: CommandGroup, names: named(commands))
public macro CommandGroup() = #externalMacro(module: "SakeMacros", type: "CommandGroupMacro")

/// A protocol representing a group of commands in the Sake project.
///
/// Types conforming to `CommandGroup` must define a set of commands
/// that can be listed and executed within the group. The protocol ensures that
/// commands are properly grouped and can be easily accessed by name.
///
/// - Note: Command names are initially based on the variable names in the group,
///   but they can be automatically converted according to a naming strategy defined
///   in the configuration (e.g., converting to snake_case or kebab-case).
public protocol CommandGroup {
    /// The name of the command group.
    ///
    /// This property defines a unique name for the group of commands.
    /// It can be used to reference or organize command groups within Sake.
    static var name: String { get }

    /// A dictionary of commands associated with the command group.
    ///
    /// Each command is stored with its name as the key, allowing
    /// for easy lookup and execution of commands by name. The names can be
    /// automatically transformed based on the configuration's strategy.
    static var commands: [String: Command] { get }
}

public extension CommandGroup {
    static var name: String {
        String(describing: Self.self)
    }
}
