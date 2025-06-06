import ArgumentParser
import Foundation
import SakeShared

struct RunCommand: SakeParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "run",
    )

    @OptionGroup
    var options: CommonOptions

    @Argument
    var command: String

    @Argument(parsing: .allUnrecognized)
    var args: [String] = []

    func run(sakeApp: SakeApp.Type) async throws {
        let commandsPreprocessor = CommandsPreprocessor(
            commands: sakeApp.commands,
            commandGroups: sakeApp.configuration.commandGroups,
            caseConvertingStrategy: options.caseConvertingStrategy,
        )
        let commands = try commandsPreprocessor.allCommands()

        if let command = commands[command] {
            let processMonitor = ProcessMonitor()
            let context = Command.Context(
                arguments: args,
                environment: ProcessInfo.processInfo.environment,
                appDirectory: Bundle.main.bundleURL.findBuildDirectory()?.deletingLastPathComponent()
                    .path ?? "<Could not find SakeApp directory>",
                runDirectory: FileManager.default.currentDirectoryPath,
                storage: Command.Context.Storage(),
                interruptionHandler: Command.Context.InterruptionHandler(processMonitor: processMonitor),
            )
            let runner = CommandRunner(command: command, context: context)
            processMonitor.monitor()
            do {
                try await runner.run()
            } catch {
                try handleRunnerError(error)
            }
        } else {
            let closestMatches = ClosestMatchFinder(candidates: Array(commands.keys)).findClosestMatches(to: command)
            throw SakeAppError.commandNotFound(command: command, closestMatches: closestMatches)
        }
    }

    private func handleRunnerError(_ error: any Error) throws {
        let errorDescription = String(describing: error)
        // little bit stupid, but it's the only way to distinguish between ArgumentParser and other errors
        if errorDescription.contains("ArgumentParser") {
            throw SakeAppError.commandArgumentsParsingFailed(command: command, error: error)
        }
        throw SakeAppError.commandRunFailed(command: command, error: error)
    }
}
