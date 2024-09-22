import Foundation

extension SakeAppManager {
    protocol FileHandle {
        var path: String { get }
        var gitignorePath: String { get }
        var packageSwiftPath: String { get }
        var sakefilePath: String { get }

        func createProjectFiles() throws
        func validatePackageSwiftExists() throws
        func isExecutableOutdated(executablePath: String) throws -> Bool
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
            // TODO: standardize path
            self.path = path ?? FileManager.default.currentDirectoryPath + "/" + defaultAppDirectoryName
        }

        func createProjectFiles() throws {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            FileManager.default.createFile(atPath: gitignorePath, contents: SakeAppContents.gitignore.data(using: .utf8), attributes: nil)
            FileManager.default.createFile(atPath: packageSwiftPath, contents: SakeAppContents.packageSwift.data(using: .utf8), attributes: nil)
            FileManager.default.createFile(atPath: sakefilePath, contents: SakeAppContents.sakefile.data(using: .utf8), attributes: nil)
        }

        func validatePackageSwiftExists() throws {
            guard FileManager.default.fileExists(atPath: packageSwiftPath) else {
                throw Error.sakeAppNotValid(.failedToFindPackageSwift(path: packageSwiftPath))
            }
        }

        func isExecutableOutdated(executablePath: String) throws -> Bool {
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
    }
}
