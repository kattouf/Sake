import SakeShared

protocol SakeAppManagerCommandExecutor {
    func swiftVersionDump() async throws -> String
    func packageDump() async throws -> String
    func packageClean() async throws
    func packageShowBinPath() async throws -> String
    func buildExecutable() async throws
    func touchExecutable(executablePath: String) async
    func callListCommandOnExecutable(executablePath: String, json: Bool, caseConvertingStrategy: CaseConvertingStrategy) async throws
    func callRunCommandOnExecutable(
        executablePath: String,
        command: String,
        args: [String],
        caseConvertingStrategy: CaseConvertingStrategy
    ) async throws
}

final class DefaultSakeAppManagerCommandExecutor: SakeAppManagerCommandExecutor {
    let fileHandle: SakeAppManagerFileHandle
    let shellExecutor: ShellExecutor

    init(fileHandle: SakeAppManagerFileHandle, shellExecutor: ShellExecutor) {
        self.fileHandle = fileHandle
        self.shellExecutor = shellExecutor
    }

    func swiftVersionDump() async throws -> String {
        let dumpResult = await shellExecutor.run("swift --version")
        guard dumpResult.succeeded else {
            throw SakeAppManagerError.failedToReadSwiftVersion(stdout: dumpResult.stdout, stderr: dumpResult.stderror)
        }
        return dumpResult.stdout
    }

    func packageDump() async throws -> String {
        let dumpResult = await shellExecutor.run("swift package dump-package --package-path \(fileHandle.path.shellQuoted)")
        guard dumpResult.succeeded else {
            throw SakeAppManagerError.sakeAppNotValid(.failedToDumpPackageSwift(
                path: fileHandle.packageSwiftPath,
                stdout: dumpResult.stdout,
                stderr: dumpResult.stderror
            ))
        }
        return dumpResult.stdout
    }

    func packageClean() async throws {
        let result = await shellExecutor.run("swift package clean --package-path \(fileHandle.path.shellQuoted)")
        if !result.succeeded {
            throw SakeAppManagerError.failedToCleanSakeApp(stdout: result.stdout, stderr: result.stderror)
        }
    }

    func packageShowBinPath() async throws -> String {
        let showBinPathResult = await shellExecutor.run("swift build --package-path \(fileHandle.path.shellQuoted) --show-bin-path")
        guard showBinPathResult.succeeded else {
            throw SakeAppManagerError.failedToReadSakeAppBinPath(stdout: showBinPathResult.stdout, stderr: showBinPathResult.stderror)
        }
        return showBinPathResult.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func buildExecutable() async throws {
        let swiftcFlags = "-Xswiftc -gnone -Xswiftc -Onone"
        let buildResult = await shellExecutor
            .run(
                "swift build --enable-experimental-prebuilts \(swiftcFlags) --package-path \(fileHandle.path.shellQuoted) --product \(Constants.sakeAppExecutableName)"
            )
        guard buildResult.succeeded else {
            throw SakeAppManagerError.failedToBuildSakeApp(stdout: buildResult.stdout, stderr: buildResult.stderror)
        }
    }

    func touchExecutable(executablePath: String) async {
        // touch -m is used to update the modification date of the executable file (used to check if it's outdated)
        await shellExecutor.run("touch -m \(executablePath.shellQuoted)")
    }

    func callListCommandOnExecutable(executablePath: String, json: Bool, caseConvertingStrategy: CaseConvertingStrategy) async throws {
        let jsonFlag = json ? " --json" : ""

        let exitCode = try await shellExecutor
            .runAndPrint(
                "\(executablePath.shellQuoted) list --case-converting-strategy \(caseConvertingStrategy.rawValue)\(jsonFlag)"
            )
        try handleSakeAppExitCode(exitCode: exitCode)
    }

    func callRunCommandOnExecutable(
        executablePath: String,
        command: String,
        args: [String],
        caseConvertingStrategy: CaseConvertingStrategy
    ) async throws {
        let args = args.isEmpty ? "" : " \(args.map { $0.shellQuoted }.joined(separator: " "))"

        let exitCode = try await shellExecutor
            .runAndPrint(
                "\(executablePath.shellQuoted) run --case-converting-strategy \(caseConvertingStrategy.rawValue) \(command)\(args)"
            )
        try handleSakeAppExitCode(exitCode: exitCode)
    }

    private func handleSakeAppExitCode(exitCode: Int) throws {
        guard exitCode != 0 else {
            return
        }
        let exitCode = Int32(exitCode)
        switch exitCode {
        case SakeAppExitCode.commandNotFound,
             SakeAppExitCode.commandRunFailed,
             SakeAppExitCode.commandDuplicate,
             SakeAppExitCode.commandArgumentsParsingFailed:
            throw SakeAppManagerError.sakeAppError(.businessError)
        default:
            throw SakeAppManagerError.sakeAppError(.unexpectedError)
        }
    }
}
