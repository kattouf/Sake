import Foundation
import SakeShared

// MARK: - Initialized mode

extension SakeAppManager where Mode == InitializedMode {
    func validateProject() async throws {
        try fileHandle.validatePackageSwiftExists()
        let dump = try await commandExecutor.packageDump()
        guard let dumpData = dump.data(using: .utf8) else {
            throw SakeAppManagerError.sakeAppNotValid(.failedToReadPackageSwift(
                path: fileHandle.packageSwiftPath,
                reason: "Can't decode as utf8 string",
            ))
        }

        let packageDescription: PackageDescription
        do {
            packageDescription = try JSONDecoder().decode(PackageDescription.self, from: dumpData)
        } catch {
            throw SakeAppManagerError.sakeAppNotValid(.failedToReadPackageSwift(
                path: fileHandle.packageSwiftPath,
                reason: "Can't decode as PackageDescription object. Error: \(error)",
            ))
        }

        guard packageDescription.products.contains(where: { $0.type.isExecutable && $0.name == Constants.sakeAppExecutableName }) else {
            throw SakeAppManagerError.sakeAppNotValid(.failedToFindSakeAppExecutableInPackageProducts(
                path: fileHandle.packageSwiftPath,
                executableName: Constants.sakeAppExecutableName,
            ))
        }
    }

    func clean() async throws {
        try await validateProject()

        log("Cleaning SakeApp package at path: \(fileHandle.path)...")
        try await commandExecutor.packageClean()
        log("SakeApp package cleaned successfully.")
    }

    func run(
        prebuiltExecutablePath: String?,
        command: String,
        args: [String],
        caseConvertingStrategy: CaseConvertingStrategy,
    ) async throws {
        let executablePath = try await getPrebuiltBinaryIfExistsOrBuildFromSource(prebuiltExecutablePath: prebuiltExecutablePath)
        try await commandExecutor.callRunCommandOnExecutable(
            executablePath: executablePath,
            command: command,
            args: args,
            caseConvertingStrategy: caseConvertingStrategy,
        )
    }

    func listAvailableCommands(prebuiltExecutablePath: String?, caseConvertingStrategy: CaseConvertingStrategy, json: Bool) async throws {
        let executablePath = try await getPrebuiltBinaryIfExistsOrBuildFromSource(prebuiltExecutablePath: prebuiltExecutablePath)
        try await commandExecutor.callListCommandOnExecutable(
            executablePath: executablePath,
            json: json,
            caseConvertingStrategy: caseConvertingStrategy,
        )
    }

    private func getPrebuiltBinaryIfExistsOrBuildFromSource(prebuiltExecutablePath: String?) async throws -> String {
        if let prebuiltExecutablePath {
            if fileHandle.isPrebuiltExecutableExists(path: prebuiltExecutablePath) {
                return prebuiltExecutablePath
            } else {
                throw SakeAppManagerError.sakeAppPrebuiltBinaryNotFound(path: prebuiltExecutablePath)
            }
        } else {
            return try await buildExecutableIfNeeded()
        }
    }

    @discardableResult
    func buildExecutableIfNeeded() async throws -> String {
        let executablePath = try await getExecutablePath()
        if try fileHandle.isExecutableOlderThenSourceFiles(executablePath: executablePath) {
            if try await isSwiftVersionWasChanged() {
                log("Swift version was changed")
                try await clean()
            }
            return try await buildExecutable()
        }

        return executablePath
    }

    @discardableResult
    func buildExecutable() async throws -> String {
        let executablePath = try await getExecutablePath()
        try await validateProject()
        log("Building SakeApp package... (this may take a moment)")
        try await commandExecutor.buildExecutable()
        // touch the executable to force update the modification date
        await commandExecutor.touchExecutable(executablePath: executablePath)
        try await saveLastUsedSwiftVersion()
        return executablePath
    }

    func getExecutablePath() async throws -> String {
        try await getBinPath() + "/" + Constants.sakeAppExecutableName
    }

    private func isSwiftVersionWasChanged() async throws -> Bool {
        guard let lastSwiftVersion = try await fileHandle.getSavedSwiftVersionDump(binPath: getBinPath()) else {
            return false
        }
        let swiftVersion = try await commandExecutor.swiftVersionDump()
        return lastSwiftVersion != swiftVersion
    }

    private func saveLastUsedSwiftVersion() async throws {
        try await fileHandle.saveSwiftVersionDump(binPath: getBinPath(), dump: swiftVersionDump())
    }

    private nonisolated(unsafe) static var swiftVersionDumpCache: String?
    private func swiftVersionDump() async throws -> String {
        if let swiftVersionDump = Self.swiftVersionDumpCache {
            return swiftVersionDump
        }

        let swiftVersionDump = try await commandExecutor.swiftVersionDump()
        Self.swiftVersionDumpCache = swiftVersionDump
        return swiftVersionDump
    }

    private nonisolated(unsafe) static var binPathCache: String?
    private func getBinPath() async throws -> String {
        if let binPath = Self.binPathCache {
            return binPath
        }

        let binPath = try await commandExecutor.packageShowBinPath()

        Self.binPathCache = binPath
        return binPath
    }
}
