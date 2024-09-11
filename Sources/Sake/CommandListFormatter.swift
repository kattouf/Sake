enum CommandListFormatter {
    static func formatted(rootName: String, rootCommands: [String: Command], groupedCommands: [String: [String: Command]]) -> String {
        let rootCommands = formattedCommandGroup(name: rootName, commands: rootCommands)
        let commandGroups = groupedCommands
            .filter { !$0.value.isEmpty }
            .map { formattedCommandGroup(name: $0.key, commands: $0.value) }
            .joined(separator: "\n")
        if commandGroups.isEmpty {
            return rootCommands
        } else {
            return "\(rootCommands)\n\(commandGroups)"
        }
    }

    private static func formattedCommandGroup(name: String, commands: [String: Command]) -> String {
        let header = "\(name):"
        let commandList = commands
            .keys
            .sorted()
            .map { commandName in
                if let description = commands[commandName]?.description {
                    return "\n * \(commandName) - \(description)"
                } else {
                    return "\n * \(commandName)"
                }
            }
            .joined()
        return "\(header)\(commandList)"
    }
}
