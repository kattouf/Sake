import ArgumentParser
import Foundation
import SwiftShell

struct BuildCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "build",
        abstract: "Manually trigger a rebuild of the SakeApp. This is typically unnecessary, but can be used to \"warm up\" the build if needed."
    )

    @OptionGroup
    var options: CommonOptions

    func run() throws {
        do {
            let configManager = ConfigManager(cliConfig: CLIConfig(commonOptions: options, commandRelatedOptions: nil))
            let config = try configManager.resolvedConfig()

            let manager = SakeAppManager.default(sakeAppPath: config.sakeAppPath)
            try manager.buildSakeAppExecutable()
        } catch {
            logError(error.localizedDescription)
            BuildCommand.exit(withError: ExitCode.failure)
        }
    }
}
