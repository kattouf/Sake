import Foundation

extension SakeAppManager {
    protocol FileHandle {
        var path: String { get }
        var gitignorePath: String { get }
        var packageSwiftPath: String { get }
        var sakefilePath: String { get }

        func createProjectFiles() throws
        func validatePackageSwiftExists() throws
        func isExecutableOlderThenSourceFiles(executablePath: String) throws -> Bool

        func getSavedSwiftVersionDump(binPath: String) throws -> String?
        func saveSwiftVersionDump(binPath: String, dump: String) throws
    }

    final class DefaultFileHandle: FileHandle {
        let path: String

        var gitignorePath: String {
            path + "/.gitignore"
        }

        var packageSwiftPath: String {
            path + "/Package.swift"
        }

        var sakefilePath: String {
            path + "/Sakefile.swift"
        }

        let defaultAppDirectoryName = "SakeApp"

        init(path: String?) {
            if let path {
                self.path = URL(fileURLWithPath: path).standardizedFileURL.path
            } else {
                self.path = FileManager.default.currentDirectoryPath + "/" + defaultAppDirectoryName
            }
        }

        func createProjectFiles() throws {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            FileManager.default.createFile(atPath: gitignorePath, contents: SakeAppContents.gitignore.data(using: .utf8), attributes: nil)
            FileManager.default.createFile(
                atPath: packageSwiftPath,
                contents: SakeAppContents.packageSwift.data(using: .utf8),
                attributes: nil
            )
            FileManager.default.createFile(atPath: sakefilePath, contents: SakeAppContents.sakefile.data(using: .utf8), attributes: nil)
        }

        func validatePackageSwiftExists() throws {
            guard FileManager.default.fileExists(atPath: packageSwiftPath) else {
                throw Error.sakeAppNotValid(.failedToFindPackageSwift(path: packageSwiftPath))
            }
        }

        func isExecutableOlderThenSourceFiles(executablePath: String) throws -> Bool {
            let sakeAppDirectoryURL = URL(fileURLWithPath: path)
            let fileManager = FileManager.default

            guard FileManager.default.fileExists(atPath: executablePath) else {
                return true
            }
            guard let binaryModificationDate = try? fileManager.attributesOfItem(atPath: executablePath)[.modificationDate] as? Date else {
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

                if isDirectory, name == ".build" {
                    enumerator.skipDescendants()
                    continue
                }

                if modificationDate > binaryModificationDate {
                    return true
                }
            }

            return false
        }

        func getSavedSwiftVersionDump(binPath: String) throws -> String? {
            let versionDumpFilePath = "\(binPath)/swift-version.txt"
            guard FileManager.default.fileExists(atPath: versionDumpFilePath) else {
                return nil
            }
            return try String(contentsOf: URL(fileURLWithPath: versionDumpFilePath), encoding: .utf8)
        }

        func saveSwiftVersionDump(binPath: String, dump: String) throws {
            let versionDumpFilePath = "\(binPath)/swift-version.txt"
            try dump.write(toFile: versionDumpFilePath, atomically: true, encoding: .utf8)
        }
    }
}
