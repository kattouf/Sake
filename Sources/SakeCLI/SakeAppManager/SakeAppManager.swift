import Foundation
import SakeShared

enum SakeAppManagerUnitializedMode {}
enum SakeAppManagerInitializedMode {}

enum SakeAppManager {}

struct _SakeAppManager<Mode>: ~Copyable {
    let fileHandle: SakeAppManager.FileHandle
    let commandExecutor: SakeAppManager.CommandExecutor
}

extension _SakeAppManager {
    static func makeDefault(sakeAppPath: String) -> Self {
        let fileHandle = SakeAppManager.DefaultFileHandle(path: sakeAppPath)
        let processMonitor = ProcessMonitor()
        processMonitor.monitor()
        let shellExecutor = ShellExecutor(processMonitor: processMonitor)
        let commandExecutor = SakeAppManager.DefaultCommandExecutor(fileHandle: fileHandle, shellExecutor: shellExecutor)
        return Self(fileHandle: fileHandle, commandExecutor: commandExecutor)
    }

    func validate() throws {
        try fileHandle.validatePackageSwiftExists()
        let dump = try commandExecutor.packageDump()
        guard let dumpData = dump.data(using: .utf8) else {
            throw SakeAppManager.Error.sakeAppNotValid(.failedToReadPackageSwift(
                path: fileHandle.packageSwiftPath,
                reason: "Can't decode as utf8 string"
            ))
        }

        let packageDescription: PackageDescription
        do {
            packageDescription = try JSONDecoder().decode(PackageDescription.self, from: dumpData)
        } catch {
            throw SakeAppManager.Error.sakeAppNotValid(.failedToReadPackageSwift(
                path: fileHandle.packageSwiftPath,
                reason: "Can't decode as PackageDescription object. Error: \(error)"
            ))
        }

        guard packageDescription.products.contains(where: { $0.type.isExecutable && $0.name == Constants.sakeAppExecutableName }) else {
            throw SakeAppManager.Error.sakeAppNotValid(.failedToFindSakeAppExecutableInPackageProducts(
                path: fileHandle.packageSwiftPath,
                executableName: Constants.sakeAppExecutableName
            ))
        }
    }
}

extension _SakeAppManager where Mode == SakeAppManagerUnitializedMode {
    consuming func initialize() throws -> _SakeAppManager<SakeAppManagerInitializedMode> {
        let alreadyExists: Bool
        do {
            try validate()
            alreadyExists = true
        } catch {
            alreadyExists = false
        }
        guard !alreadyExists else {
            throw SakeAppManager.Error.sakeAppAlreadyInitialized(path: fileHandle.path)
        }

        log("Creating SakeApp package at path: \(fileHandle.path)...")
        try fileHandle.createProjectFiles()

        try validate()
        log("SakeApp package initialized successfully.")

        return _SakeAppManager<SakeAppManagerInitializedMode>(fileHandle: fileHandle, commandExecutor: commandExecutor)
    }
}

extension _SakeAppManager where Mode == SakeAppManagerInitializedMode {
    func clean() throws {
        try validate()

        log("Cleaning SakeApp package at path: \(fileHandle.path)...")
        try commandExecutor.packageClean()
        log("SakeApp package cleaned successfully.")
    }

    func run(prebuiltExecutablePath: String?, command: String, args: [String], caseConvertingStrategy: CaseConvertingStrategy) throws {
        let executablePath = try getPrebuiltBinaryIfExistsyOrBuildFromSource(prebuiltExecutablePath: prebuiltExecutablePath)
        try commandExecutor.callRunCommandOnExecutable(
            executablePath: executablePath,
            command: command,
            args: args,
            caseConvertingStrategy: caseConvertingStrategy
        )
    }

    func listAvailableCommands(prebuiltExecutablePath: String?, caseConvertingStrategy: CaseConvertingStrategy, json: Bool) throws {
        let executablePath = try getPrebuiltBinaryIfExistsyOrBuildFromSource(prebuiltExecutablePath: prebuiltExecutablePath)
        try commandExecutor.callListCommandOnExecutable(
            executablePath: executablePath,
            json: json,
            caseConvertingStrategy: caseConvertingStrategy
        )
    }

    private func getPrebuiltBinaryIfExistsyOrBuildFromSource(prebuiltExecutablePath: String?) throws -> String {
        if let prebuiltExecutablePath {
            if fileHandle.isPrebuiltExecutableExists(path: prebuiltExecutablePath) {
                return prebuiltExecutablePath
            } else {
                throw SakeAppManager.Error.sakeAppPrebuiltBinaryNotFound(path: prebuiltExecutablePath)
            }
        } else {
            return try buildSakeAppExecutableIfNeeded()
        }
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

    func getExecutablePath() throws -> String {
        try getBinPath() + "/" + Constants.sakeAppExecutableName
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

    private nonisolated(unsafe) static var swiftVersionDumpCache: String?
    private func swiftVersionDump() throws -> String {
        if let swiftVersionDump = Self.swiftVersionDumpCache {
            return swiftVersionDump
        }

        let swiftVersionDump = try commandExecutor.swiftVersionDump()
        Self.swiftVersionDumpCache = swiftVersionDump
        return swiftVersionDump
    }

    private nonisolated(unsafe) static var binPathCache: String?
    private func getBinPath() throws -> String {
        if let binPath = Self.binPathCache {
            return binPath
        }

        let binPath = try commandExecutor.packageShowBinPath()

        Self.binPathCache = binPath
        return binPath
    }
}
