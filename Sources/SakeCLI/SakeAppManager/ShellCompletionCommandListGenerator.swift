import ArgumentParser
import Foundation
import SakeShared

enum ShellCompletionCommandListGenerator {
    @Sendable
    static func generate(arguments: [String]) -> [String] {
        let semaphore = DispatchSemaphore(value: 0)
        var result: [String] = []

        Task {
            result = await generateAsync(arguments: arguments)
            semaphore.signal()
        }

        semaphore.wait()
        return result
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

private extension SakeAppManager where Mode == InitializedMode {
    func getListAvailableCommandsOutputIfExecutablePresented(caseConvertingStrategy: CaseConvertingStrategy, json: Bool) async -> String? {
        guard let executablePath = try? await getExecutablePath(), FileManager.default.fileExists(atPath: executablePath) else {
            return nil
        }
        return await commandExecutor.callListCommandOnExecutableAndCaptureOutput(
            executablePath: executablePath,
            json: json,
            caseConvertingStrategy: caseConvertingStrategy,
        )
    }
}

private extension SakeAppManagerCommandExecutor {
    func callListCommandOnExecutableAndCaptureOutput(
        executablePath: String,
        json: Bool,
        caseConvertingStrategy: CaseConvertingStrategy
    ) async -> String? {
        let shellExecutor = ShellExecutor()

        let jsonFlag = json ? " --json" : ""
        let command = "\(executablePath.shellQuoted) list --case-converting-strategy \(caseConvertingStrategy.rawValue)\(jsonFlag)"

        let result = await shellExecutor.run(command)
        return result.succeeded ? result.stdout : nil
    }
}
