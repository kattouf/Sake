import ArgumentParser
import Foundation
import SakeShared

public extension SakeApp {
    static func main() throws {
        do {
            let cliCommand = try CLI.parseAsRoot()
            switch cliCommand {
            case let listCommand as ListCommand:
                try Self.listCommand(listCommand)
            case let runCommand as RunCommand:
                try Self.runCommand(runCommand)
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

    private static func commandsConvenientProvider(options: CommonOptions) -> CommandsConvenientProvider {
        CommandsConvenientProvider(
            commands: commands,
            commandGroups: configuration.commandGroups,
            caseConvertingStrategy: options.caseConvertingStrategy
        )
    }

    private static func runCommand(_ runCommand: RunCommand) throws {
        let commandsProvider = commandsConvenientProvider(options: runCommand.options)
        let commands = try commandsProvider.allCommands()

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
    }

    private static func listCommand(_ listCommand: ListCommand) throws {
        let commandsProvider = commandsConvenientProvider(options: listCommand.options)
        let rootCommands = commandsProvider.rootCommands()
        let commandGroups = commandsProvider.otherCommandGroups()

        let formatterInputData = CommandListFormatter.InputData(rootName: Self.name, rootCommands: rootCommands, groupedCommands: commandGroups)
        let formatted = if listCommand.options.json {
            try CommandListFormatter.json(inputData: formatterInputData)
        } else {
            CommandListFormatter.humanReadable(inputData: formatterInputData)
        }
        print(formatted)
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
}
