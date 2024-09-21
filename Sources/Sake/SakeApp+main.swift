import ArgumentParser
import Foundation
import SakeShared

public extension SakeApp {
    static func main() throws {
        do {
            let cliCommand = try CLI.parseAsRoot()
            switch cliCommand {
            case let listCommand as ListCommand:
                let rootCommands = rootCommands(caseConvertingStrategy: listCommand.options.caseConvertingStrategy)
                let commandGroups = commandGroups(caseConvertingStrategy: listCommand.options.caseConvertingStrategy)
                let formatterInputData = CommandListFormatter.InputData(rootName: Self.name, rootCommands: rootCommands, groupedCommands: commandGroups)
                let formatted = if listCommand.options.json {
                    try CommandListFormatter.json(inputData: formatterInputData)
                } else {
                    CommandListFormatter.humanReadable(inputData: formatterInputData)
                }
                print(formatted)
            case let runCommand as RunCommand:
                let commands = try allCommands(caseConvertingStrategy: runCommand.options.caseConvertingStrategy)
                if let command = commands[runCommand.command] {
                    let context = Command.Context(arguments: runCommand.args, environment: ProcessInfo.processInfo.environment)
                    let runner = CommandRunner(command: command, context: context)
                    do {
                        try runner.run()
                    } catch {
                        let errorDescription = String(describing: error)
                        // little bit stupid, but it's the only way to distinguish between ArgumentParser and other errors
                        if errorDescription.contains("ArgumentParser") {
                            throw SakeAppError.commandArgumentsParsingFailed(command: runCommand.command, error: error)
                        }
                        throw SakeAppError.commandRunFailed(command: runCommand.command, error: error)
                    }
                } else {
                    let closestMatches = ClosestMatchFinder(candidates: Array(commands.keys)).findClosestMatches(to: runCommand.command)
                    throw SakeAppError.commandNotFound(command: runCommand.command, closestMatches: closestMatches)
                }
            default:
                throw SakeAppError.unexpectedError(message: "Impossible runtime state")
            }
        } catch {
            let exitCode: Int32 = exitCode(for: error)
            if exitCode == SakeAppExitCode.unexpectedError {
                logError(String(describing: error))
            } else {
                logError(error.localizedDescription)
            }
            CLI.exit(withError: ExitCode(exitCode))
        }
    }

    private static func exitCode(for error: Error) -> Int32 {
        if case let sakeAppError as SakeAppError = error {
            switch sakeAppError {
            case .unexpectedError: SakeAppExitCode.unexpectedError
            case .commandNotFound: SakeAppExitCode.commandNotFound
            case .commandRunFailed: SakeAppExitCode.commandRunFailed
            case .commandDuplicate: SakeAppExitCode.commandDuplicate
            case .commandArgumentsParsingFailed: SakeAppExitCode.commandArgumentsParsingFailed
            }
        } else {
            SakeAppExitCode.unexpectedError
        }
    }

    private static func allCommands(caseConvertingStrategy: CaseConvertingStrategy) throws -> [String: Command] {
        let rootCommands = rootCommands(caseConvertingStrategy: caseConvertingStrategy)
        let commandGroups = commandGroups(caseConvertingStrategy: caseConvertingStrategy).values.flatMap { $0 }
        let commandNamesIntersection = Set(rootCommands.keys).intersection(Set(commandGroups.map(\.key)))
        guard commandNamesIntersection.isEmpty else {
            throw SakeAppError.commandDuplicate(command: commandNamesIntersection.first!)
        }
        return rootCommands.merging(commandGroups) { $1 }
    }

    private static func rootCommands(caseConvertingStrategy: CaseConvertingStrategy) -> [String: Command] {
        return adjustCommandsNames(commands, caseConvertingStrategy: caseConvertingStrategy)
    }

    private static func commandGroups(caseConvertingStrategy: CaseConvertingStrategy) -> [String: [String: Command]] {
        let commandGroups = Self.configuration.commandGroups
        var result: [String: [String: Command]] = [:]
        for group in commandGroups {
            let groupName = group.name
            let commands = adjustCommandsNames(group.commands, caseConvertingStrategy: caseConvertingStrategy)
            result[groupName] = commands
        }
        return result
    }

    private static func adjustCommandsNames(_ commands: [String: Command], caseConvertingStrategy: CaseConvertingStrategy) -> [String: Command] {
        let commandNames = Array(commands.keys)

        let adjustedCommandNames: [String] = switch caseConvertingStrategy {
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
