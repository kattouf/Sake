import Foundation
import SakeShared

// MARK: - Initialized mode

extension SakeAppManager where Mode == InitializedMode {
    func validateProject() throws {
        try fileHandle.validatePackageSwiftExists()
        let dump = try commandExecutor.packageDump()
        guard let dumpData = dump.data(using: .utf8) else {
            throw SakeAppManagerError.sakeAppNotValid(.failedToReadPackageSwift(
                path: fileHandle.packageSwiftPath,
                reason: "Can't decode as utf8 string"
            ))
        }

        let packageDescription: PackageDescription
        do {
            packageDescription = try JSONDecoder().decode(PackageDescription.self, from: dumpData)
        } catch {
            throw SakeAppManagerError.sakeAppNotValid(.failedToReadPackageSwift(
                path: fileHandle.packageSwiftPath,
                reason: "Can't decode as PackageDescription object. Error: \(error)"
            ))
        }

        guard packageDescription.products.contains(where: { $0.type.isExecutable && $0.name == Constants.sakeAppExecutableName }) else {
            throw SakeAppManagerError.sakeAppNotValid(.failedToFindSakeAppExecutableInPackageProducts(
                path: fileHandle.packageSwiftPath,
                executableName: Constants.sakeAppExecutableName
            ))
        }
    }

    func clean() throws {
        try validateProject()

        log("Cleaning SakeApp package at path: \(fileHandle.path)...")
        try commandExecutor.packageClean()
        log("SakeApp package cleaned successfully.")
    }

    func run(prebuiltExecutablePath: String?, command: String, args: [String], caseConvertingStrategy: CaseConvertingStrategy) throws {
        let executablePath = try getPrebuiltBinaryIfExistsOrBuildFromSource(prebuiltExecutablePath: prebuiltExecutablePath)
        try commandExecutor.callRunCommandOnExecutable(
            executablePath: executablePath,
            command: command,
            args: args,
            caseConvertingStrategy: caseConvertingStrategy
        )
    }

    func listAvailableCommands(prebuiltExecutablePath: String?, caseConvertingStrategy: CaseConvertingStrategy, json: Bool) throws {
        let executablePath = try getPrebuiltBinaryIfExistsOrBuildFromSource(prebuiltExecutablePath: prebuiltExecutablePath)
        try commandExecutor.callListCommandOnExecutable(
            executablePath: executablePath,
            json: json,
            caseConvertingStrategy: caseConvertingStrategy
        )
    }

    private func getPrebuiltBinaryIfExistsOrBuildFromSource(prebuiltExecutablePath: String?) throws -> String {
        if let prebuiltExecutablePath {
            if fileHandle.isPrebuiltExecutableExists(path: prebuiltExecutablePath) {
                return prebuiltExecutablePath
            } else {
                throw SakeAppManagerError.sakeAppPrebuiltBinaryNotFound(path: prebuiltExecutablePath)
            }
        } else {
            return try buildExecutableIfNeeded()
        }
    }

    @discardableResult
    func buildExecutableIfNeeded() throws -> String {
        let executablePath = try getExecutablePath()
        if try fileHandle.isExecutableOlderThenSourceFiles(executablePath: executablePath) {
            if try isSwiftVersionWasChanged() {
                log("Swift version was changed")
                try clean()
            }
            return try buildExecutable()
        }

        return executablePath
    }

    @discardableResult
    func buildExecutable() throws -> String {
        let executablePath = try getExecutablePath()
        try validateProject()
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
