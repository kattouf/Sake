import Foundation

enum CommandListFormatter {
    struct Data {
        let rootName: String
        let rootCommands: [String: Command]
        let groupedCommands: [String: [String: Command]]
    }

    private struct CommandGroupsJSON: Encodable {
        struct Command: Encodable {
            let name: String
            let description: String?
        }

        let groups: [String: [Command]]
    }

    static func humanReadable(data: Data) -> String {
        let rootCommands = formattedCommandGroup(name: data.rootName, commands: data.rootCommands)
        let commandGroups = data.groupedCommands
            .filter { !$0.value.isEmpty }
            .map { formattedCommandGroup(name: $0.key, commands: $0.value) }
            .joined(separator: "\n")
        if commandGroups.isEmpty {
            return rootCommands
        } else {
            return "\(rootCommands)\n\(commandGroups)"
        }
    }

    static func json(data: Data) throws -> String {
        var groups = [String: [CommandGroupsJSON.Command]]()
        groups[data.rootName] = data.rootCommands.map { .init(name: $0.key, description: $0.value.description) }
        data.groupedCommands.forEach { groupName, commands in
            groups[groupName] = commands.map { .init(name: $0.key, description: $0.value.description) }
        }
        let commandGroupsJSON = CommandGroupsJSON(groups: groups)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(commandGroupsJSON)
        return String(data: jsonData, encoding: .utf8)!
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
