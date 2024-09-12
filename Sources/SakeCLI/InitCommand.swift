import ArgumentParser
import Foundation
import SwiftShell

struct InitCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Initialize a new SakeApp project template for defining commands."
    )

    @OptionGroup
    var options: CommonOptions

    func run() throws {
        do {
            let configManager = ConfigManager(cliConfig: CLIConfig(commonOptions: options, commandRelatedOptions: nil))
            let config = try configManager.resolvedConfig()

            let manager = SakeAppManager(path: config.sakeAppPath)
            try manager.initialize()
        } catch {
            logError(error.localizedDescription)
            InitCommand.exit(withError: ExitCode.failure)
        }
    }
}