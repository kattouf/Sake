import ArgumentParser
import Foundation
import SakeCLILibrary

struct RunCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "run",
        abstract: "Run the specified command from the SakeApp.",
    )

    @OptionGroup
    var options: CommonOptions

    @OptionGroup
    var commandRelatedOptions: CommandRelatedCommonOptions

    @Argument(
        help: "The name of the command to execute.",
        completion: .custom(ShellCompletionCommandListGenerator.generate), // For some reasons new async API makes runtime errors
    )
    var command: String

    @Argument(parsing: .allUnrecognized, help: "Arguments to pass to the command.")
    var args: [String] = []

    func run() async throws {
        do {
            let configManager = ConfigManager(cliConfig: CLIConfig(commonOptions: options, commandRelatedOptions: commandRelatedOptions))
            let config = try configManager.resolvedConfig()

            let manager: SakeAppManager<InitializedMode> = try .makeInInitializedMode(sakeAppPath: config.sakeAppPath)
            try await manager.run(
                prebuiltExecutablePath: config.sakeAppPrebuiltBinaryPath,
                command: command,
                args: args,
                caseConvertingStrategy: config.caseConvertingStrategy,
            )
        } catch {
            if case let SakeAppManagerError.sakeAppError(sakeAppError) = error {
                // log only unexpected errors, business errors are already pretty logged by the SakeApp
                if case SakeAppManagerError.SakeAppError.unexpectedError = sakeAppError {
                    logError(error.localizedDescription)
                }
            } else {
                logError(error.localizedDescription)
            }
            RunCommand.exit(withError: ExitCode.failure)
        }
    }
}
