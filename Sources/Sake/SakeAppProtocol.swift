/// A protocol representing the main application in the Sake project.
///
/// Types conforming to `SakeApp` serve as the entry point for organizing and managing
/// command groups. It extends `CommandGroup`, meaning that an app can define and group commands
/// while also providing a configuration for managing multiple command groups.
public protocol SakeApp: CommandGroup {

    /// The configuration for the Sake app, specifying the command groups available.
    ///
    /// The command groups provided in this configuration will be available for execution
    /// from the terminal.
    static var configuration: SakeAppConfiguration { get }
}

public extension SakeApp {
    static var configuration: SakeAppConfiguration {
        SakeAppConfiguration()
    }
}

/// A structure representing the configuration of a Sake app.
///
/// The `SakeAppConfiguration` defines the command groups that will be available for execution
/// from the terminal.
public struct SakeAppConfiguration {

    /// The command groups included in the Sake app.
    ///
    /// These command groups will be available for invocation from the terminal.
    public let commandGroups: [CommandGroup.Type]

    /// Initializes a new `SakeAppConfiguration` with the specified command groups.
    ///
    /// - Parameter commandGroups: An array of command group types to be made available for execution.
    ///   Defaults to an empty array.
    public init(commandGroups: [CommandGroup.Type] = []) {
        self.commandGroups = commandGroups
    }
}
