import SakeShared

final class CommandsConvenientProvider {
    let commands: [String: Command]
    let commandGroups: [CommandGroup.Type]
    let caseConvertingStrategy: CaseConvertingStrategy

    init(commands: [String: Command], commandGroups: [CommandGroup.Type], caseConvertingStrategy: CaseConvertingStrategy) {
        self.commands = commands
        self.commandGroups = commandGroups
        self.caseConvertingStrategy = caseConvertingStrategy
    }

    func allCommands() throws -> [String: Command] {
        let rootCommands = rootCommands()
        let commandGroups = otherCommandGroups().values.flatMap { $0 }
        let commandNamesIntersection = Set(rootCommands.keys).intersection(Set(commandGroups.map(\.key)))
        guard commandNamesIntersection.isEmpty else {
            throw SakeAppError.commandDuplicate(command: commandNamesIntersection.first!)
        }
        return rootCommands.merging(commandGroups) { $1 }
    }

    func rootCommands() -> [String: Command] {
        CommandNameCaseConverter.convert(commands, strategy: caseConvertingStrategy)
    }

    func otherCommandGroups() -> [String: [String: Command]] {
        var result: [String: [String: Command]] = [:]
        for group in commandGroups {
            let groupName = group.name
            let commands = CommandNameCaseConverter.convert(group.commands, strategy: caseConvertingStrategy)
            result[groupName] = commands
        }
        return result
    }
}
