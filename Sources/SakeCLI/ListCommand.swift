import ArgumentParser
import Foundation
import SakeCLILibrary

struct ListCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all available commands defined in the SakeApp.",
        aliases: ["ls"],
    )

    @OptionGroup
    var options: CommonOptions

    @OptionGroup
    var commandRelatedOptions: CommandRelatedCommonOptions

    @Flag(name: .shortAndLong, help: "Output the result in JSON format.")
    var json: Bool = false

    func run() async throws {
        do {
            let configManager = ConfigManager(cliConfig: CLIConfig(commonOptions: options, commandRelatedOptions: commandRelatedOptions))
            let config = try configManager.resolvedConfig()

            let manager: SakeAppManager<InitializedMode> = try .makeInInitializedMode(sakeAppPath: config.sakeAppPath)
            try await manager.listAvailableCommands(
                prebuiltExecutablePath: config.sakeAppPrebuiltBinaryPath,
                caseConvertingStrategy: config.caseConvertingStrategy,
                json: json,
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
            ListCommand.exit(withError: ExitCode.failure)
        }
    }
}
