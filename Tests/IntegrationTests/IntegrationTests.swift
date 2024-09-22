import SwiftShell
import XCTest

final class IntegrationTests: XCTestCase {
    func testHelloWorld() throws {
        let isRunningFromGitHubActions = ProcessInfo.processInfo.environment["GITHUB_ACTIONS"] == "true"
        let workDirectory = isRunningFromGitHubActions ? URL(filePath: FileManager.default.currentDirectoryPath) : FileManager.default.temporaryDirectory
        let tempDirectory = workDirectory.appendingPathComponent(UUID().uuidString)
        let testProjectPath = tempDirectory.appendingPathComponent("test-project").path
        try FileManager.default.createDirectory(atPath: testProjectPath, withIntermediateDirectories: true, attributes: nil)

        let sakeInitResult = SwiftShell.run(bash: "cd \(testProjectPath); sake init")
        XCTAssertTrue(sakeInitResult.succeeded)

        let sakeRunResult = SwiftShell.run(bash: "cd \(testProjectPath); sake hello")
        XCTAssertTrue(sakeRunResult.succeeded)
        XCTAssertTrue(sakeRunResult.stdout.contains("Hello, world!"))

        try FileManager.default.removeItem(atPath: workDirectory.path)
    }
}
