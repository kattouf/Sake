@testable import SakeCLI
import XCTest

final class DefaultFileHandleTests: XCTestCase {
    func testAbosultePath() {
        let fileHandle = SakeAppManager.DefaultFileHandle(path: "/path/to/sakeapp")
        XCTAssertEqual(fileHandle.path, "/path/to/sakeapp")
    }

    func testRelativePath() {
        let fileHandle = SakeAppManager.DefaultFileHandle(path: "path/to/sakeapp")
        XCTAssertEqual(fileHandle.path, FileManager.default.currentDirectoryPath + "/path/to/sakeapp")

        let fileHandle2 = SakeAppManager.DefaultFileHandle(path: "./path/to/sakeapp")
        XCTAssertEqual(fileHandle2.path, FileManager.default.currentDirectoryPath + "/path/to/sakeapp")
    }

    func testCreateProjectFiles() throws {
        let fileHandle = SakeAppManager.DefaultFileHandle(path: "/tmp/sakeapp")
        try fileHandle.createProjectFiles()

        XCTAssertTrue(FileManager.default.fileExists(atPath: fileHandle.gitignorePath))
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileHandle.packageSwiftPath))
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileHandle.sakefilePath))

        try FileManager.default.removeItem(atPath: fileHandle.path)
    }

    func testValidatePackageSwiftExists() throws {
        let fileHandle = SakeAppManager.DefaultFileHandle(path: "/tmp/sakeapp")
        try fileHandle.createProjectFiles()

        try fileHandle.validatePackageSwiftExists()

        try FileManager.default.removeItem(atPath: fileHandle.path)
    }

    func testIsExecutableOutdated() throws {
        let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let fileHandle = SakeAppManager.DefaultFileHandle(path: tempDirectory.path)
        try fileHandle.createProjectFiles()

        let executablePath = tempDirectory.appendingPathComponent(".build").appendingPathComponent("my-exec").path
        try FileManager.default.createDirectory(atPath: URL(filePath: executablePath).deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: nil)

        FileManager.default.createFile(atPath: executablePath, contents: nil, attributes: nil)
        XCTAssertFalse(try fileHandle.isExecutableOutdated(executablePath: executablePath))

        try "jepa".write(toFile: fileHandle.sakefilePath, atomically: true, encoding: .utf8)
        XCTAssertTrue(try fileHandle.isExecutableOutdated(executablePath: executablePath))

        FileManager.default.createFile(atPath: executablePath, contents: nil, attributes: nil)
        XCTAssertFalse(try fileHandle.isExecutableOutdated(executablePath: executablePath))

        try FileManager.default.removeItem(atPath: fileHandle.path)
    }
}