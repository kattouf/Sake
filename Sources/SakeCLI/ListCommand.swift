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

    @Flag(name: .shortAndLong, help: "Output the result in JSON format.")
    var json: Bool = false

    func run() throws {
        do {
            let configManager = ConfigManager(cliConfig: CLIConfig(commonOptions: options, commandRelatedOptions: commandRelatedOptions))
            let config = try configManager.resolvedConfig()

            let manager = SakeAppManager.default(sakeAppPath: config.sakeAppPath)
            try manager.listAvailableCommands(caseConvertingStrategy: config.caseConvertingStrategy, json: json)
        } catch {
            if case let SakeAppManager.Error.sakeAppError(sakeAppError) = error {
                // log only unexpected errors, business errors are already pretty logged by the SakeApp
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
