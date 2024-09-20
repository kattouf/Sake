import Foundation
import SakeShared
import SwiftShell

private enum Constants {
    // just "sake" dir name leads to a conflict with the sake package name and error: "error: cyclic dependency declaration found"
    static let defaultAppDirectoryName = "SakeApp"
    static let executableName = "SakeApp"
}

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

final class SakeAppManager {
    let path: String

    private var gitignorePath: String {
        path + "/.gitignore"
    }

    private var packageSwiftPath: String {
        path + "/Package.swift"
    }

    private var sakefilePath: String {
        path + "/Sakefile.swift"
    }

    init(path: String?) {
        self.path = path ?? FileManager.default.currentDirectoryPath + "/" + Constants.defaultAppDirectoryName
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
            throw Error.sakeAppAlreadyInitialized(path: path)
        }

        log("Creating SakeApp package at path: \(path)...")
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        FileManager.default.createFile(atPath: gitignorePath, contents: SakeAppContents.gitignore.data(using: .utf8), attributes: nil)
        FileManager.default.createFile(atPath: packageSwiftPath, contents: SakeAppContents.packageSwift.data(using: .utf8), attributes: nil)
        FileManager.default.createFile(atPath: sakefilePath, contents: SakeAppContents.sakefile.data(using: .utf8), attributes: nil)

        try buildSakeAppExecutable()
        log("SakeApp package initialized successfully.")
    }

    func clean() throws {
        try validate()

        log("Cleaning SakeApp package at path: \(path)...")
        let result = SwiftShell.run(bash: "swift package clean --package-path \(path)")
        if result.succeeded {
            log("SakeApp package cleaned successfully.")
        } else {
            throw Error.failedToCleanSakeApp(stdout: result.stdout, stderr: result.stderror)
        }
    }

    func validate() throws {
        guard FileManager.default.fileExists(atPath: packageSwiftPath) else {
            throw Error.sakeAppNotValid(.failedToFindPackageSwift(path: packageSwiftPath))
        }

        let dumpResult = SwiftShell.run(bash: "swift package dump-package --package-path \(path)")
        guard dumpResult.succeeded else {
            throw Error.sakeAppNotValid(.failedToDumpPackageSwift(path: packageSwiftPath, stdout: dumpResult.stdout, stderr: dumpResult.stderror))
        }
        guard let dumpData = dumpResult.stdout.data(using: .utf8) else {
            throw Error.sakeAppNotValid(.failedToReadPackageSwift(path: packageSwiftPath, reason: "Can't decode as utf8 string"))
        }

        let packageDescription: PackageDescription
        do {
            packageDescription = try JSONDecoder().decode(PackageDescription.self, from: dumpData)
        } catch {
            throw Error.sakeAppNotValid(.failedToReadPackageSwift(path: packageSwiftPath, reason: "Can't decode as PackageDescription object. Error: \(error)"))
        }

        guard packageDescription.products.contains(where: { $0.type.isExecutable && $0.name == Constants.executableName }) else {
            throw Error.sakeAppNotValid(.failedToFindSakeAppExecutableInPackageProducts(path: packageSwiftPath, executableName: Constants.executableName))
        }
    }

    func run(command: String, args: [String], caseConvertingStrategy: CaseConvertingStrategy) throws {
        try validate()

        let executablePath = try buildSakeAppExecutable()
        let args = args.isEmpty ? "" : " \(args.joined(separator: " "))"

        do {
            try SwiftShell.runAndPrint(bash: "\(executablePath) run --case-converting-strategy \(caseConvertingStrategy.rawValue) \(command)\(args)")
        } catch let SwiftShell.CommandError.returnedErrorCode(_, exitCode) {
            try handleSakeAppExitCode(exitCode: exitCode)
        }
    }

    func listAvailableCommands(caseConvertingStrategy: CaseConvertingStrategy, json: Bool) throws {
        try validate()

        let executablePath = try buildSakeAppExecutable()
        let jsonFlag = json ? " --json" : ""

        do {
            try SwiftShell.runAndPrint(bash: "\(executablePath) list --case-converting-strategy \(caseConvertingStrategy.rawValue)\(jsonFlag)")
        } catch let SwiftShell.CommandError.returnedErrorCode(_, exitCode) {
            try handleSakeAppExitCode(exitCode: exitCode)
        }
    }

    private func handleSakeAppExitCode(exitCode: Int) throws {
        let exitCode = Int32(exitCode)
        switch exitCode {
        case SakeAppExitCode.commandNotFound, SakeAppExitCode.commandRunFailed, SakeAppExitCode.commandDuplicate, SakeAppExitCode.commandArgumentsParsingFailed:
            throw Error.sakeAppError(.businessError)
        default:
            throw Error.sakeAppError(.unexpectedError)
        }
    }

    @discardableResult
    private func buildSakeAppExecutable() throws -> String {
        if try isSakeAppBinaryOutdated() {
            log("Building SakeApp package... (this may take a moment)")
            let executablePath = try getExecutablePath()
            let buildResult = SwiftShell.run(bash: "swift build --package-path \(path) --product \(Constants.executableName) && touch -m \(executablePath)")
            guard buildResult.succeeded else {
                throw Error.failedToBuildSakeApp(stdout: buildResult.stdout, stderr: buildResult.stderror)
            }
        }

        return try getExecutablePath()
    }

    private func isSakeAppBinaryOutdated() throws -> Bool {
        let sakeAppDirectoryURL = URL(fileURLWithPath: path)
        let fileManager = FileManager.default
        let executablePath = try getExecutablePath()

        guard FileManager.default.fileExists(atPath: executablePath) else {
            return true
        }
        guard let binaryModificationDate = try fileManager.attributesOfItem(atPath: executablePath)[.modificationDate] as? Date else {
            return true
        }

        let urlResourceKeys: Set<URLResourceKey> = [.isDirectoryKey, .nameKey, .attributeModificationDateKey]
        let enumerator = fileManager.enumerator(
            at: sakeAppDirectoryURL,
            includingPropertiesForKeys: Array(urlResourceKeys),
            options: []
        )!

        for case let fileURL as URL in enumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: urlResourceKeys),
                  let isDirectory = resourceValues.isDirectory,
                  let name = resourceValues.name,
                  let modificationDate = resourceValues.attributeModificationDate
            else {
                continue
            }

            if isDirectory && name == ".build" {
                enumerator.skipDescendants()
                continue
            }

            if modificationDate > binaryModificationDate {
                return true
            }
        }

        return false
    }

    private func getExecutablePath() throws -> String {
        enum Cache {
            static var executablePath: String?
        }

        if let executablePath = Cache.executablePath {
            return executablePath
        }

        let showBinPathResult = SwiftShell.run(bash: "swift build --package-path \(path) --show-bin-path")
        guard showBinPathResult.succeeded else {
            throw Error.failedToReadSakeAppBinPath(stdout: showBinPathResult.stdout, stderr: showBinPathResult.stderror)
        }
        let binPath = showBinPathResult.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        let executablePath = binPath + "/" + Constants.executableName

        Cache.executablePath = executablePath
        return executablePath
    }
}
