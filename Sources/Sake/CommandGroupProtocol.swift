@attached(extension, conformances: CommandGroup, names: named(commands))
public macro CommandGroup() = #externalMacro(module: "SakeMacros", type: "CommandGroupMacro")

public protocol CommandGroup {
    static var name: String { get }
    static var commands: [String: Command] { get }
}

public extension CommandGroup {
    static var name: String {
        String(describing: Self.self)
    }
}
