import Foundation
import SakeShared

package extension SakeAppManager where Mode == InitializedMode {
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
