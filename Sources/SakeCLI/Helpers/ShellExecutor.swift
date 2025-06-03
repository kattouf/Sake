import Foundation
import SakeShared
import SwiftShell

final class ShellExecutor {
    struct RunOutput {
        let succeeded: Bool
        let stdout: String
        let stderror: String
        let error: SwiftShell.CommandError?
    }

    private let processMonitor: ProcessMonitor

    init(processMonitor: ProcessMonitor) {
        self.processMonitor = processMonitor
    }

    func runAndPrint(_ command: String) async throws {
        let currentShell = getCurrentShell()
        let asyncCommand = SwiftShell.runAsyncAndPrint(currentShell, "-c", command)
        processMonitor.addProcess(asyncCommand)
        try asyncCommand.finish()
    }

    @discardableResult
    func run(_ command: String) async -> RunOutput {
        var stdout: String?
        var stderror: String?

        let currentShell = getCurrentShell()
        let asyncCommand = SwiftShell.runAsync(currentShell, "-c", command)
        processMonitor.addProcess(asyncCommand)

        // Workaround: https://github.com/kareman/SwiftShell/issues/52
        let readOutStreams = DispatchWorkItem {
            stdout = asyncCommand.stdout.read()
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let readErrorStreams = DispatchWorkItem {
            stderror = asyncCommand.stderror.read()
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        DispatchQueue.global().async(execute: readOutStreams)
        DispatchQueue.global().async(execute: readErrorStreams)
        readOutStreams.wait()
        readErrorStreams.wait()

        stdout = stdout.map(cleanUpOutput)
        stderror = stderror.map(cleanUpOutput)
        let error: SwiftShell.CommandError?
        let succeeded: Bool

        do {
            try asyncCommand.finish()
            succeeded = true
            error = nil
        } catch let commandError as CommandError {
            succeeded = false
            error = commandError
        } catch {
            fatalError("Unexpected error: \(error)")
        }

        return RunOutput(succeeded: succeeded, stdout: stdout ?? "", stderror: stderror ?? "", error: error)
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
