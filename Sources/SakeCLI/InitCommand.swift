import ArgumentParser
import Foundation
import SwiftShell

struct InitCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Initialize a new SakeApp project template for defining commands."
    )

    @OptionGroup
    var options: CommonOptions

    func run() throws {
        do {
            let configManager = ConfigManager(cliConfig: CLIConfig(commonOptions: options, commandRelatedOptions: nil))
            let config = try configManager.resolvedConfig()

            let uninitializedManager = SakeAppManager<UninitializedMode>.makeDefault(sakeAppPath: config.sakeAppPath)
            let initializedSakeAppManager = try uninitializedManager.initializeProject()
            try initializedSakeAppManager.buildExecutable()
        } catch {
            logError(error.localizedDescription)
            InitCommand.exit(withError: ExitCode.failure)
        }
    }
}
