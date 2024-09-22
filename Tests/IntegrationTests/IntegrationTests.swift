import SwiftShell
import XCTest

final class IntegrationTests: XCTestCase {
    func testHelloWorld() throws {
        let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let sakeAppPath = tempDirectory.appendingPathComponent("my-sake-app").path

        let sakeInitResult = SwiftShell.run(bash: "sake init --sake-app-path \(sakeAppPath)")
        if !sakeInitResult.succeeded {
            XCTFail("Failed to init Sake app: stdout: \(sakeInitResult.stdout), stderr: \(sakeInitResult.stderror)")
        }

        let sakeRunResult = SwiftShell.run(bash: "sake hello --sake-app-path \(sakeAppPath)")
        if sakeRunResult.succeeded {
            XCTAssertTrue(sakeRunResult.stdout.contains("Hello, world!"))
        } else {
            XCTFail("Failed to run Sake app: stdout: \(sakeRunResult.stdout), stderr: \(sakeRunResult.stderror)")
        }

        try FileManager.default.removeItem(atPath: tempDirectory.path)
    }
}
