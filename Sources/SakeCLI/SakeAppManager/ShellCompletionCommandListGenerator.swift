import ArgumentParser
import Foundation
import SakeShared
import SwiftShell

enum ShellCompletionCommandListGenerator {
    @Sendable
    static func generate(arguments: [String]) -> [String] {
        do {
            let arguments = try RunCommand.parse(arguments)

            let configManager = ConfigManager(cliConfig: CLIConfig(
                commonOptions: arguments.options,
                commandRelatedOptions: arguments.commandRelatedOptions
            ))
            let config = try configManager.resolvedConfig()

            let manager: SakeAppManager<InitializedMode> = try .makeInInitializedMode(sakeAppPath: config.sakeAppPath)
            guard
                let commandsListJSON = manager.getListAvailableCommandsOutputIfExecutablePresented(
                    caseConvertingStrategy: config.caseConvertingStrategy,
                    json: true
                ),
                let commandsListJSONData = commandsListJSON.data(using: .utf8)
            else {
                return []
            }
            let commandGroups = try JSONDecoder().decode(CommandGroupsJSON.self, from: commandsListJSONData)
            return commandGroups.groups.values.flatMap { $0.map(\.name) }
        } catch {
            return []
        }
    }
}

private extension SakeAppManager where Mode == InitializedMode {
    func getListAvailableCommandsOutputIfExecutablePresented(caseConvertingStrategy: CaseConvertingStrategy, json: Bool) -> String? {
        guard let executablePath = try? getExecutablePath(), FileManager.default.fileExists(atPath: executablePath) else {
            return nil
        }
        return commandExecutor.callListCommandOnExecutableAndCaptureOutput(
            executablePath: executablePath,
            json: json,
            caseConvertingStrategy: caseConvertingStrategy
        )
    }
}

private extension SakeAppManagerCommandExecutor {
    func callListCommandOnExecutableAndCaptureOutput(
        executablePath: String,
        json: Bool,
        caseConvertingStrategy: CaseConvertingStrategy
    ) -> String? {
        let jsonFlag = json ? " --json" : ""
        let result = SwiftShell.run(bash: "\(executablePath) list --case-converting-strategy \(caseConvertingStrategy.rawValue)\(jsonFlag)")
        return result.succeeded ? result.stdout : nil
    }
}
