import SakeShared
import SwiftShell

extension SakeAppManager {
    protocol CommandExecutor {
        func swiftVersionDump() throws -> String
        func packageDump() throws -> String
        func packageClean() throws
        func packageShowBinPath() throws -> String
        func buildExecutable() throws
        func touchExecutable(executablePath: String)
        func callListCommandOnExecutable(executablePath: String, json: Bool, caseConvertingStrategy: CaseConvertingStrategy) throws
        func callRunCommandOnExecutable(
            executablePath: String,
            command: String,
            args: [String],
            caseConvertingStrategy: CaseConvertingStrategy
        ) throws
    }

    final class DefaultCommandExecutor: CommandExecutor {
        let fileHandle: FileHandle
        let shellExecutor: ShellExecutor

        init(fileHandle: FileHandle, shellExecutor: ShellExecutor) {
            self.fileHandle = fileHandle
            self.shellExecutor = shellExecutor
        }

        func swiftVersionDump() throws -> String {
            let dumpResult = shellExecutor.run("swift --version")
            guard dumpResult.succeeded else {
                throw Error.failedToReadSwiftVersion(stdout: dumpResult.stdout, stderr: dumpResult.stderror)
            }
            return dumpResult.stdout
        }

        func packageDump() throws -> String {
            let dumpResult = shellExecutor.run("swift package dump-package --package-path \(fileHandle.path)")
            guard dumpResult.succeeded else {
                throw Error.sakeAppNotValid(.failedToDumpPackageSwift(
                    path: fileHandle.packageSwiftPath,
                    stdout: dumpResult.stdout,
                    stderr: dumpResult.stderror
                ))
            }
            return dumpResult.stdout
        }

        func packageClean() throws {
            let result = shellExecutor.run("swift package clean --package-path \(fileHandle.path)")
            if !result.succeeded {
                throw Error.failedToCleanSakeApp(stdout: result.stdout, stderr: result.stderror)
            }
        }

        func packageShowBinPath() throws -> String {
            let showBinPathResult = shellExecutor.run("swift build --package-path \(fileHandle.path) --show-bin-path")
            guard showBinPathResult.succeeded else {
                throw Error.failedToReadSakeAppBinPath(stdout: showBinPathResult.stdout, stderr: showBinPathResult.stderror)
            }
            return showBinPathResult.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        func buildExecutable() throws {
            let swiftcFlags = "-Xswiftc -gnone -Xswiftc -Onone"
            let buildResult = shellExecutor
                .run("swift build \(swiftcFlags) --package-path \(fileHandle.path) --product \(Constants.sakeAppExecutableName)")
            guard buildResult.succeeded else {
                throw Error.failedToBuildSakeApp(stdout: buildResult.stdout, stderr: buildResult.stderror)
            }
        }

        func touchExecutable(executablePath: String) {
            // touch -m is used to update the modification date of the executable file (used to check if it's outdated)
            shellExecutor.run("touch -m \(executablePath)")
        }

        func callListCommandOnExecutable(executablePath: String, json: Bool, caseConvertingStrategy: CaseConvertingStrategy) throws {
            let jsonFlag = json ? " --json" : ""

            do {
                try shellExecutor
                    .runAndPrint("\(executablePath) list --case-converting-strategy \(caseConvertingStrategy.rawValue)\(jsonFlag)")
            } catch let SwiftShell.CommandError.returnedErrorCode(_, exitCode) {
                try handleSakeAppExitCode(exitCode: exitCode)
            }
        }

        func callRunCommandOnExecutable(
            executablePath: String,
            command: String,
            args: [String],
            caseConvertingStrategy: CaseConvertingStrategy
        ) throws {
            let args = args.isEmpty ? "" : " \(args.joined(separator: " "))"

            do {
                try shellExecutor
                    .runAndPrint(
                        "\(executablePath) run --case-converting-strategy \(caseConvertingStrategy.rawValue) \(command)\(args)"
                    )
            } catch let SwiftShell.CommandError.returnedErrorCode(_, exitCode) {
                try handleSakeAppExitCode(exitCode: exitCode)
            }
        }

        private func handleSakeAppExitCode(exitCode: Int) throws {
            let exitCode = Int32(exitCode)
            switch exitCode {
            case SakeAppExitCode.commandNotFound,
                 SakeAppExitCode.commandRunFailed,
                 SakeAppExitCode.commandDuplicate,
                 SakeAppExitCode.commandArgumentsParsingFailed:
                throw Error.sakeAppError(.businessError)
            default:
                throw Error.sakeAppError(.unexpectedError)
            }
        }
    }
}
