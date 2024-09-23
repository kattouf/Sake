import Foundation

enum CommandListFormatter {
    struct InputData {
        let rootName: String
        let rootCommands: [String: Command]
        let groupedCommands: [String: [String: Command]]
    }

    static func json(inputData: InputData) throws -> String {
        var groups = [String: [CommandGroupsJSON.Command]]()
        groups[inputData.rootName] = inputData.rootCommands.map { .init(name: $0.key, description: $0.value.description) }
        for (groupName, commands) in inputData.groupedCommands {
            groups[groupName] = commands.map { .init(name: $0.key, description: $0.value.description) }
        }
        let commandGroupsJSON = CommandGroupsJSON(groups: groups)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(commandGroupsJSON)
        return String(data: jsonData, encoding: .utf8)!
    }

    static func humanReadable(inputData: InputData) -> String {
        let rootCommands = formattedCommandGroup(name: inputData.rootName, commands: inputData.rootCommands)
        let commandGroups = inputData.groupedCommands
            .filter { !$0.value.isEmpty }
            .sorted { $0.key < $1.key }
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
                    "\n * \(commandName) - \(description)"
                } else {
                    "\n * \(commandName)"
                }
            }
            .joined()
        return "\(header)\(commandList)"
    }
}

private extension CommandListFormatter {
    struct CommandGroupsJSON: Encodable {
        struct Command: Encodable {
            let name: String
            let description: String?
        }

        let groups: [String: [Command]]
    }
}
