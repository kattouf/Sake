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
        try buildSakeAppExecutableIfNeeded()
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
        let executablePath = try buildSakeAppExecutableIfNeeded()
        try commandExecutor.callRunCommandOnExecutable(
            executablePath: executablePath,
            command: command,
            args: args,
            caseConvertingStrategy: caseConvertingStrategy
        )
    }

    func listAvailableCommands(caseConvertingStrategy: CaseConvertingStrategy, json: Bool) throws {
        let executablePath = try buildSakeAppExecutableIfNeeded()
        try commandExecutor.callListCommandOnExecutable(
            executablePath: executablePath,
            json: json,
            caseConvertingStrategy: caseConvertingStrategy
        )
    }

    @discardableResult
    func buildSakeAppExecutableIfNeeded() throws -> String {
        let executablePath = try getExecutablePath()
        if try fileHandle.isExecutableOlderThenSourceFiles(executablePath: executablePath) {
            if try isSwiftVersionWasChanged() {
                log("Swift version was changed")
                try clean()
            }
            return try buildSakeAppExecutable()
        }

        return executablePath
    }

    @discardableResult
    func buildSakeAppExecutable() throws -> String {
        let executablePath = try getExecutablePath()
        try validate()
        log("Building SakeApp package... (this may take a moment)")
        try commandExecutor.buildExecutable()
        // touch the executable to force update the modification date
        commandExecutor.touchExecutable(executablePath: executablePath)
        try saveLastUsedSwiftVersion()
        return executablePath
    }

    private func isSwiftVersionWasChanged() throws -> Bool {
        guard let lastSwiftVersion = try fileHandle.getSavedSwiftVersionDump(binPath: getBinPath()) else {
            return false
        }
        let swiftVersion = try commandExecutor.swiftVersionDump()
        return lastSwiftVersion != swiftVersion
    }

    private func saveLastUsedSwiftVersion() throws {
        try fileHandle.saveSwiftVersionDump(binPath: getBinPath(), dump: swiftVersionDump())
    }

    private func swiftVersionDump() throws -> String {
        enum Cache {
            nonisolated(unsafe) static var swiftVersionDump: String?
        }

        if let swiftVersionDump = Cache.swiftVersionDump {
            return swiftVersionDump
        }

        let swiftVersionDump = try commandExecutor.swiftVersionDump()
        Cache.swiftVersionDump = swiftVersionDump
        return swiftVersionDump
    }

    private func getExecutablePath() throws -> String {
        try getBinPath() + "/" + Constants.sakeAppExecutableName
    }

    private func getBinPath() throws -> String {
        enum Cache {
            nonisolated(unsafe) static var binPath: String?
        }

        if let binPath = Cache.binPath {
            return binPath
        }

        let binPath = try commandExecutor.packageShowBinPath()

        Cache.binPath = binPath
        return binPath
    }
}
