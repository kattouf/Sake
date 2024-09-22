import Foundation

extension SakeAppManager {
    enum Error: Swift.Error {
        case sakeAppAlreadyInitialized(path: String)
        case sakeAppNotValid(ValidationError)

        case failedToCleanSakeApp(stdout: String, stderr: String)
        case failedToBuildSakeApp(stdout: String, stderr: String)
        case failedToReadSakeAppBinPath(stdout: String, stderr: String)

        case sakeAppError(SakeAppError)
    }

    enum SakeAppError: Swift.Error {
        case businessError
        case unexpectedError
    }

    enum ValidationError: Swift.Error {
        case failedToFindPackageSwift(path: String)
        case failedToDumpPackageSwift(path: String, stdout: String, stderr: String)
        case failedToReadPackageSwift(path: String, reason: String)
        case failedToFindSakeAppExecutableInPackageProducts(path: String, executableName: String)
    }
}

extension SakeAppManager.ValidationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .failedToFindPackageSwift(path):
            return "Failed to find 'Package.swift' at \(path)."
        case let .failedToDumpPackageSwift(path, stdout, stderr):
            return """
            Failed to dump 'Package.swift' at \(path).
            Stdout:
            \"\"\"
            \(stdout.isEmpty ? "<No output>" : stdout)
            \"\"\"
            Stderr:
            \"\"\"
            \(stderr.isEmpty ? "<No output>" : stderr)
            \"\"\"
            """
        case let .failedToReadPackageSwift(path, reason):
            return "Failed to read 'Package.swift' at \(path). Reason: \(reason)."
        case let .failedToFindSakeAppExecutableInPackageProducts(path, executableName):
            return "Failed to find the '\(executableName)' executable in 'Package.swift' products at \(path)."
        }
    }
}

extension SakeAppManager.SakeAppError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .businessError:
            return "Business error."
        case .unexpectedError:
            return "Unexpected error."
        }
    }
}

extension SakeAppManager.Error: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .sakeAppAlreadyInitialized(path):
            return "SakeApp already initialized at \(path)."
        case let .sakeAppNotValid(error):
            return "SakeApp is not valid. \(error.localizedDescription)"
        case let .failedToCleanSakeApp(stdout, stderr):
            return """
            Failed to clean SakeApp.
            Stdout:
            \"\"\"
            \(stdout.isEmpty ? "<No output>" : stdout)
            \"\"\"
            Stderr:
            \"\"\"
            \(stderr.isEmpty ? "<No output>" : stderr)
            \"\"\"
            """
        case let .failedToBuildSakeApp(stdout, stderr):
            return """
            Failed to build SakeApp.
            Stdout:
            \"\"\"
            \(stdout.isEmpty ? "<No output>" : stdout)
            \"\"\"
            Stderr:
            \"\"\"
            \(stderr.isEmpty ? "<No output>" : stderr)
            \"\"\"
            """
        case let .failedToReadSakeAppBinPath(stdout, stderr):
            return """
            Failed to read the SakeApp binary path.
            Stdout:
            \"\"\"
            \(stdout.isEmpty ? "<No output>" : stdout)
            \"\"\"
            Stderr:
            \"\"\"
            \(stderr.isEmpty ? "<No output>" : stderr)
            \"\"\"
            """
        case let .sakeAppError(error):
            return "SakeApp error. \(error.localizedDescription)"
        }
    }
}
