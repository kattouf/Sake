import Foundation
import SakeShared
import Subprocess
#if canImport(System)
    import System
#else
    import SystemPackage
#endif

final class ShellExecutor {
    struct RunOutput {
        let succeeded: Bool
        let stdout: String
        let stderror: String
        let executorError: Error?
    }

    @discardableResult
    func runAndPrint(_ command: String) async throws -> Int {
        let currentShell = getCurrentShell()

        let result = try await Subprocess.run(
            .path(FilePath(currentShell)),
            arguments: ["-c", command],
            input: .fileDescriptor(.standardInput, closeAfterSpawningProcess: false),
            output: .fileDescriptor(.standardOutput, closeAfterSpawningProcess: false),
            error: .fileDescriptor(.standardError, closeAfterSpawningProcess: false)
        )
        return result.terminationStatus.exitCode
    }

    @discardableResult
    func run(_ command: String) async -> RunOutput {
        let currentShell = getCurrentShell()

        do {
            let result = try await Subprocess.run(
                .path(FilePath(currentShell)),
                arguments: ["-c", command],
                input: .none,
                output: .string(limit: 512 * 1024, encoding: UTF8.self),
                error: .string(limit: 512 * 1024, encoding: UTF8.self)
            )
            return RunOutput(
                succeeded: result.terminationStatus.isSuccess,
                stdout: result.standardOutput.map(cleanUpOutput) ?? "",
                stderror: result.standardError.map(cleanUpOutput) ?? "",
                executorError: nil
            )
        } catch {
            return RunOutput(
                succeeded: false,
                stdout: "",
                stderror: "",
                executorError: error
            )
        }
    }
}

// MARK: - Utils

private extension ShellExecutor {
    func getCurrentShell() -> String {
        guard let shell = ProcessInfo.processInfo.environment["SHELL"] else {
            return "/bin/bash"
        }
        return shell
    }

    /// If text is single-line, trim it.
    func cleanUpOutput(_ text: String) -> String {
        let afterfirstnewline = text.firstIndex(of: "\n").map(text.index(after:))
        return (afterfirstnewline == nil || afterfirstnewline == text.endIndex)
            ? text.trimmingCharacters(in: .whitespacesAndNewlines)
            : text
    }
}

private extension TerminationStatus {
    var exitCode: Int {
        switch self {
        case let .exited(code):
            Int(code)
        case let .unhandledException(code):
            Int(code)
        }
    }
}
