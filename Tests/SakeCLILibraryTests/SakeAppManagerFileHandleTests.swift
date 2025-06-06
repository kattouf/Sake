@testable import SakeCLILibrary
import XCTest

final class DefaultFileHandleTests: XCTestCase {
    func testAbosultePath() {
        let fileHandle = DefaultSakeAppManagerFileHandle(path: "/path/to/sakeapp")
        XCTAssertEqual(fileHandle.path, "/path/to/sakeapp")
    }

    func testRelativePath() {
        let fileHandle = DefaultSakeAppManagerFileHandle(path: "path/to/sakeapp")
        XCTAssertEqual(fileHandle.path, FileManager.default.currentDirectoryPath + "/path/to/sakeapp")

        let fileHandle2 = DefaultSakeAppManagerFileHandle(path: "./path/to/sakeapp")
        XCTAssertEqual(fileHandle2.path, FileManager.default.currentDirectoryPath + "/path/to/sakeapp")
    }

    func testCreateProjectFiles() throws {
        let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).path
        let fileHandle = DefaultSakeAppManagerFileHandle(path: tempDirectory)
        try fileHandle.createProjectFiles()

        XCTAssertTrue(FileManager.default.fileExists(atPath: fileHandle.gitignorePath))
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileHandle.packageSwiftPath))
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileHandle.sakefilePath))

        try FileManager.default.removeItem(atPath: fileHandle.path)
    }

    func testValidatePackageSwiftExists() throws {
        let fileHandle = DefaultSakeAppManagerFileHandle(path: "/tmp/sakeapp")
        try fileHandle.createProjectFiles()

        try fileHandle.validatePackageSwiftExists()

        try FileManager.default.removeItem(atPath: fileHandle.path)
    }

    func testSaveAndGetSwiftVersionDump() throws {
        let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).path
        let fileHandle = DefaultSakeAppManagerFileHandle(path: tempDirectory)
        let buildPath = fileHandle.path + "/.build"
        try FileManager.default.createDirectory(atPath: buildPath, withIntermediateDirectories: true, attributes: nil)

        try fileHandle.saveSwiftVersionDump(binPath: buildPath, dump: "4.2.0")
        let dump = try fileHandle.getSavedSwiftVersionDump(binPath: buildPath)

        XCTAssertEqual(dump, "4.2.0")

        try FileManager.default.removeItem(atPath: fileHandle.path)
    }

    func testIsExecutableOutdated() throws {
        let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let fileHandle = DefaultSakeAppManagerFileHandle(path: tempDirectory.path)
        try fileHandle.createProjectFiles()

        let executablePath = tempDirectory.appendingPathComponent(".build").appendingPathComponent("my-exec").path
        try FileManager.default.createDirectory(
            atPath: URL(fileURLWithPath: executablePath).deletingLastPathComponent().path,
            withIntermediateDirectories: true,
            attributes: nil,
        )

        FileManager.default.createFile(atPath: executablePath, contents: nil, attributes: nil)
        XCTAssertFalse(try fileHandle.isExecutableOlderThenSourceFiles(executablePath: executablePath))

        try FileManager.default.setAttributes([.modificationDate: Date()], ofItemAtPath: fileHandle.sakefilePath)
        XCTAssertTrue(try fileHandle.isExecutableOlderThenSourceFiles(executablePath: executablePath))

        try FileManager.default.setAttributes([.modificationDate: Date()], ofItemAtPath: executablePath)
        XCTAssertFalse(try fileHandle.isExecutableOlderThenSourceFiles(executablePath: executablePath))

        try FileManager.default.removeItem(atPath: fileHandle.path)
    }

    func testIsExecutableDoesNotBecomeOutdatedDueToHiddenFiles() throws {
        let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let fileHandle = DefaultSakeAppManagerFileHandle(path: tempDirectory.path)
        try fileHandle.createProjectFiles()

        let hiddenDirectory = tempDirectory.appendingPathComponent(".hidden")
        try FileManager.default.createDirectory(atPath: hiddenDirectory.path, withIntermediateDirectories: true, attributes: nil)
        let hiddenFilePath = hiddenDirectory.appendingPathComponent("hidden.swift").path

        let executablePath = tempDirectory.appendingPathComponent(".build").appendingPathComponent("my-exec").path
        try FileManager.default.createDirectory(
            atPath: URL(fileURLWithPath: executablePath).deletingLastPathComponent().path,
            withIntermediateDirectories: true,
            attributes: nil,
        )

        FileManager.default.createFile(atPath: hiddenFilePath, contents: nil, attributes: nil)

        FileManager.default.createFile(atPath: executablePath, contents: nil, attributes: nil)
        XCTAssertFalse(try fileHandle.isExecutableOlderThenSourceFiles(executablePath: executablePath))

        try FileManager.default.setAttributes([.modificationDate: Date()], ofItemAtPath: hiddenFilePath)
        XCTAssertFalse(try fileHandle.isExecutableOlderThenSourceFiles(executablePath: executablePath))

        try FileManager.default.setAttributes([.modificationDate: Date()], ofItemAtPath: fileHandle.sakefilePath)
        XCTAssertTrue(try fileHandle.isExecutableOlderThenSourceFiles(executablePath: executablePath))

        try FileManager.default.removeItem(atPath: fileHandle.path)
    }
}
