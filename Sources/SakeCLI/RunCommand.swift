import ArgumentParser
import Foundation
import SwiftShell

struct RunCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "run",
        abstract: "Run the specified command from the SakeApp."
    )

    @OptionGroup
    var options: CommonOptions

    @OptionGroup
    var commandRelatedOptions: CommandRelatedCommonOptions

    @Argument
    var command: String

    @Argument(parsing: .allUnrecognized)
    var args: [String] = []

    func run() throws {
        do {
            let configManager = ConfigManager(cliConfig: CLIConfig(commonOptions: options, commandRelatedOptions: commandRelatedOptions))
            let config = try configManager.resolvedConfig()

            let manager = SakeAppManager(path: config.sakeAppPath)
            try manager.run(command: command, args: args, caseConvertingStrategy: config.caseConvertingStrategy)
        } catch {
            if case let SakeAppManager.Error.sakeAppError(sakeAppError) = error {
                // log only unexpected errors, as the expected ones are already logged by SakeApp itself
                if case SakeAppManager.SakeAppError.unexpectedError = sakeAppError {
                    logError(error.localizedDescription)
                }
            } else {
                logError(error.localizedDescription)
            }
            RunCommand.exit(withError: ExitCode.failure)
        }
    }
}
