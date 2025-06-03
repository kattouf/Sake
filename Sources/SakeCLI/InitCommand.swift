import ArgumentParser
import Foundation
import SwiftShell

struct InitCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Initialize a new SakeApp project template for defining commands."
    )

    @OptionGroup
    var options: CommonOptions

    func run() async throws {
        do {
            let configManager = ConfigManager(cliConfig: CLIConfig(commonOptions: options, commandRelatedOptions: nil))
            let config = try configManager.resolvedConfig()

            let uninitializedModeManager: SakeAppManager<UninitializedMode> = .makeInUninitializedMode(sakeAppPath: config.sakeAppPath)
            let initializedModeManager = try await uninitializedModeManager.initializeProject()
            try await initializedModeManager.buildExecutable()
        } catch {
            logError(error.localizedDescription)
            InitCommand.exit(withError: ExitCode.failure)
        }
    }
}
