public protocol SakeApp: CommandGroup {
    static var configuration: SakeAppConfiguration { get }
}

public extension SakeApp {
    static var configuration: SakeAppConfiguration {
        SakeAppConfiguration()
    }
}

public struct SakeAppConfiguration {
    public let commandGroups: [CommandGroup.Type]

    public init(commandGroups: [CommandGroup.Type] = []) {
        self.commandGroups = commandGroups
    }
}
