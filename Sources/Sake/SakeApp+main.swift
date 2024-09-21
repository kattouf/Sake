import ArgumentParser
import Foundation
import SakeShared

public extension SakeApp {
    static func main() throws {
        do {
            let cliCommand = try CLI.parseAsRoot()
            if case let sakeCommand as SakeParsableCommand = cliCommand {
                try sakeCommand.run(sakeApp: self)
            } else {
                throw SakeAppError.unexpectedError(message: "Impossible runtime state")
            }
        } catch {
            let exitCode: Int32 = exitCode(for: error)
            if exitCode == SakeAppExitCode.unexpectedError {
                logError(String(describing: error))
            } else {
                logError(error.localizedDescription)
            }
            CLI.exit(withError: ExitCode(exitCode))
        }
    }

    private static func exitCode(for error: Error) -> Int32 {
        if case let sakeAppError as SakeAppError = error {
            switch sakeAppError {
            case .unexpectedError: SakeAppExitCode.unexpectedError
            case .commandNotFound: SakeAppExitCode.commandNotFound
            case .commandRunFailed: SakeAppExitCode.commandRunFailed
            case .commandDuplicate: SakeAppExitCode.commandDuplicate
            case .commandArgumentsParsingFailed: SakeAppExitCode.commandArgumentsParsingFailed
            }
        } else {
            SakeAppExitCode.unexpectedError
        }
    }
}
