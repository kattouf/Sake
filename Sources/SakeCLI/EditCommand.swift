import ArgumentParser
import Foundation
import SakeShared
import SwiftShell

struct EditCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "edit",
        abstract: "Open the SakeApp in Xcode"
    )

    @OptionGroup
    var options: CommonOptions

    func run() throws {
        do {
            let configManager = ConfigManager(cliConfig: CLIConfig(commonOptions: options, commandRelatedOptions: nil))
            let config = try configManager.resolvedConfig()

            #if os(macOS)
                try openXcode(config.sakeAppPath)
            #else
                logError("Unsupported platform")
            #endif
        } catch {
            logError(error.localizedDescription)
            EditCommand.exit(withError: ExitCode.failure)
        }
    }

    private func openXcode(_ sakeAppPath: String) throws {
        let processMonitor = ProcessMonitor()
        processMonitor.monitor()
        let executor = ShellExecutor(processMonitor: processMonitor)
        try executor.runAndPrint("xed \(sakeAppPath)")
    }
}
