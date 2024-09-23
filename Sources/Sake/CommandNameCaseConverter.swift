import SakeShared

enum CommandNameCaseConverter {
    static func convert(_ commands: [String: Command], strategy: CaseConvertingStrategy) -> [String: Command] {
        let commandNames = Array(commands.keys)

        let adjustedCommandNames: [String] = switch strategy {
        case .keepOriginal:
            commandNames
        case .toSnakeCase:
            commandNames.map { $0.toSnakeCase() }
        case .toKebabCase:
            commandNames.map { $0.toKebabCase() }
        }

        return Dictionary(uniqueKeysWithValues: zip(adjustedCommandNames, commands.values))
    }
}
