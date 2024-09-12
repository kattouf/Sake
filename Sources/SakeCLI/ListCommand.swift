import ArgumentParser
import Foundation
import SwiftShell

struct ListCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all available commands defined in the SakeApp."
    )

    @OptionGroup
    var options: CommonOptions

    @OptionGroup
    var commandRelatedOptions: CommandRelatedCommonOptions

    func run() throws {
        do {
            let configManager = ConfigManager(cliConfig: CLIConfig(commonOptions: options, commandRelatedOptions: commandRelatedOptions))
            let config = try configManager.resolvedConfig()

            let manager = SakeAppManager(path: config.sakeAppPath)
            try manager.listAvailableCommands(caseConvertingStrategy: config.caseConvertingStrategy)
        } catch {
            if case let SakeAppManager.Error.sakeAppError(sakeAppError) = error {
                // log only unexpected errors, as the expected ones are already logged by SakeApp itself
                if case SakeAppManager.SakeAppError.unexpectedError = sakeAppError {
                    logError(error.localizedDescription)
                }
            } else {
                logError(error.localizedDescription)
            }
            ListCommand.exit(withError: ExitCode.failure)
        }
    }
}