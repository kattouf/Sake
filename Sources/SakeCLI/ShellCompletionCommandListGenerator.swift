import ArgumentParser
import Foundation
import SakeCLILibrary
import SakeShared

enum ShellCompletionCommandListGenerator {
    private final class UncheckedSendable: @unchecked Sendable {
        var value: [String] = []
    }

    @Sendable
    static func generate(arguments: [String]) -> [String] {
        let semaphore = DispatchSemaphore(value: 0)
        let resultBox = UncheckedSendable()

        Task {
            resultBox.value = await generateAsync(arguments: arguments)
            semaphore.signal()
        }

        semaphore.wait()
        return resultBox.value
    }

    @Sendable
    static func generateAsync(arguments: [String]) async -> [String] {
        do {
            let arguments = try RunCommand.parse(arguments)

            let configManager = ConfigManager(cliConfig: CLIConfig(
                commonOptions: arguments.options,
                commandRelatedOptions: arguments.commandRelatedOptions,
            ))
            let config = try configManager.resolvedConfig()

            let manager: SakeAppManager<InitializedMode> = try .makeInInitializedMode(sakeAppPath: config.sakeAppPath)
            guard
                let commandsListJSON = await manager.getListAvailableCommandsOutputIfExecutablePresented(
                    caseConvertingStrategy: config.caseConvertingStrategy,
                    json: true,
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
