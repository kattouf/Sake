import Foundation
import SakeShared

final class SakeAppManager {
    let fileHandle: FileHandle
    let commandExecutor: CommandExecutor

    static func `default`(sakeAppPath: String?) -> Self {
        let fileHandle = DefaultFileHandle(path: sakeAppPath)
        let commandExecutor = DefaultCommandExecutor(fileHandle: fileHandle)
        return Self(fileHandle: fileHandle, commandExecutor: commandExecutor)
    }

    init(fileHandle: FileHandle, commandExecutor: CommandExecutor) {
        self.fileHandle = fileHandle
        self.commandExecutor = commandExecutor
    }

    func initialize() throws {
        let alreadyExists: Bool
        do {
            try validate()
            alreadyExists = true
        } catch {
            alreadyExists = false
        }
        guard !alreadyExists else {
            throw Error.sakeAppAlreadyInitialized(path: fileHandle.path)
        }

        log("Creating SakeApp package at path: \(fileHandle.path)...")
        try fileHandle.createProjectFiles()

        try validate()
        try buildSakeAppExecutable()
        log("SakeApp package initialized successfully.")
    }

    func clean() throws {
        try validate()

        log("Cleaning SakeApp package at path: \(fileHandle.path)...")
        try commandExecutor.packageClean()
        log("SakeApp package cleaned successfully.")
    }

    func validate() throws {
        try fileHandle.validatePackageSwiftExists()
        let dump = try commandExecutor.packageDump()
        guard let dumpData = dump.data(using: .utf8) else {
            throw Error.sakeAppNotValid(.failedToReadPackageSwift(path: fileHandle.packageSwiftPath, reason: "Can't decode as utf8 string"))
        }

        let packageDescription: PackageDescription
        do {
            packageDescription = try JSONDecoder().decode(PackageDescription.self, from: dumpData)
        } catch {
            throw Error.sakeAppNotValid(.failedToReadPackageSwift(
                path: fileHandle.packageSwiftPath,
                reason: "Can't decode as PackageDescription object. Error: \(error)"
            ))
        }

        guard packageDescription.products.contains(where: { $0.type.isExecutable && $0.name == Constants.sakeAppExecutableName }) else {
            throw Error.sakeAppNotValid(.failedToFindSakeAppExecutableInPackageProducts(
                path: fileHandle.packageSwiftPath,
                executableName: Constants.sakeAppExecutableName
            ))
        }
    }

    func run(command: String, args: [String], caseConvertingStrategy: CaseConvertingStrategy) throws {
        let executablePath = try buildSakeAppExecutable()
        try commandExecutor.callRunCommandOnExecutable(
            executablePath: executablePath,
            command: command,
            args: args,
            caseConvertingStrategy: caseConvertingStrategy
        )
    }

    func listAvailableCommands(caseConvertingStrategy: CaseConvertingStrategy, json: Bool) throws {
        let executablePath = try buildSakeAppExecutable()
        try commandExecutor.callListCommandOnExecutable(
            executablePath: executablePath,
            json: json,
            caseConvertingStrategy: caseConvertingStrategy
        )
    }

    @discardableResult
    private func buildSakeAppExecutable() throws -> String {
        let executablePath = try getExecutablePath()
        if try fileHandle.isExecutableOutdated(executablePath: executablePath) {
            try validate()
            log("Building SakeApp package... (this may take a moment)")
            try commandExecutor.buildExecutable()
            // touch the executable to update the modification date
            commandExecutor.touchExecutable(executablePath: executablePath)
        }

        return try getExecutablePath()
    }

    private func getExecutablePath() throws -> String {
        enum Cache {
            nonisolated(unsafe) static var executablePath: String?
        }

        if let executablePath = Cache.executablePath {
            return executablePath
        }

        let binPath = try commandExecutor.packageShowBinPath()
        let executablePath = binPath + "/" + Constants.sakeAppExecutableName

        Cache.executablePath = executablePath
        return executablePath
    }
}
