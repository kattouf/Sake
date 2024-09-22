import SwiftShell
import XCTest

final class IntegrationTests: XCTestCase {
    func testHelloWorld() throws {
        let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let sakeAppPath = tempDirectory.appendingPathComponent("my-sake-app").path

        let sakeInitResult = SwiftShell.run(bash: "sake init --sake-app-path \(sakeAppPath)")
        XCTAssertTrue(sakeInitResult.succeeded)

        let sakeRunResult = SwiftShell.run(bash: "sake hello --sake-app-path \(sakeAppPath)")
        XCTAssertTrue(sakeRunResult.succeeded)
        XCTAssertTrue(sakeRunResult.stdout.contains("Hello, world!"))

        try FileManager.default.removeItem(atPath: tempDirectory.path)
    }
}
