import ArgumentParser
import Foundation

enum SakeAppError: Error {
    case commandNotFound(command: String, closestMatches: [String])
    case commandRunFailed(command: String, error: Error)
    case commandDuplicate(command: String)
    case commandArgumentsParsingFailed(command: String, error: Error)
    case unexpectedError(message: String)
}

extension SakeAppError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .commandNotFound(command, closestMatches):
            if !closestMatches.isEmpty {
                let formattedClosestMatches = closestMatches.map { "\"\($0)\"" }.joined(separator: ", ")
                return """
                Command \"\(command)\" not found. Did you mean: \(formattedClosestMatches)?
                Run \"sake list\" to see all available commands.
                """
            }
            return """
            Command \"\(command)\" not found.
            Run \"sake list\" to see all available commands.
            """
        case let .commandRunFailed(command, error):
            return "Command \"\(command)\" failed with error: \(error)."
        case let .commandDuplicate(command):
            return "Command \"\(command)\" is duplicated."
        case let .commandArgumentsParsingFailed(command, error):
            let errorMessage = DummyParsableArguments.message(for: error)
            return "Failed to parse arguments for command \"\(command)\": \(errorMessage)."
        case let .unexpectedError(message):
            return "Unexpected error: \(message)."
        }
    }
}

// Needed to get the error message from the ArgumentParser
private struct DummyParsableArguments: ParsableArguments {}
