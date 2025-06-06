import ArgumentParser
import Foundation
import SakeCLILibrary
import SakeShared

struct EditCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "edit",
        abstract: "Open the SakeApp in Xcode",
    )

    @OptionGroup
    var options: CommonOptions

    func run() async throws {
        do {
            let configManager = ConfigManager(cliConfig: CLIConfig(commonOptions: options, commandRelatedOptions: nil))
            let config = try configManager.resolvedConfig()

            #if os(macOS)
                try await openXcode(config.sakeAppPath)
            #else
                logError("Unsupported platform")
            #endif
        } catch {
            logError(error.localizedDescription)
            EditCommand.exit(withError: ExitCode.failure)
        }
    }

    private func openXcode(_ sakeAppPath: String) async throws {
        let executor = ShellExecutor()
        try await executor.runAndPrint("xed \(sakeAppPath)")
    }
}
