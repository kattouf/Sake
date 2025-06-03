import ArgumentParser
import Foundation

struct BuildCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "build",
        abstract: "Manually trigger a rebuild of the SakeApp. This is typically unnecessary, but can be used to \"warm up\" the build if needed."
    )

    @OptionGroup
    var options: CommonOptions

    @Flag(name: .long, help: "Print the path to the built SakeApp executable.")
    var showBinPath: Bool = false

    func run() async throws {
        do {
            let configManager = ConfigManager(cliConfig: CLIConfig(commonOptions: options, commandRelatedOptions: nil))
            let config = try configManager.resolvedConfig()

            let manager: SakeAppManager<InitializedMode> = try .makeInInitializedMode(sakeAppPath: config.sakeAppPath)
            if showBinPath {
                let binPath = try await manager.getExecutablePath()
                print(binPath)
            } else {
                try await manager.buildExecutable()
            }
        } catch {
            logError(error.localizedDescription)
            BuildCommand.exit(withError: ExitCode.failure)
        }
    }
}
