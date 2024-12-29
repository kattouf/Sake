import SakeShared
import SwiftShell
import XCTest

final class IntegrationTests: XCTestCase {
    func testHelloWorld() throws {
        let packagePath = try XCTUnwrap(URL(fileURLWithPath: #file).findBuildDirectory()?.deletingLastPathComponent().path)

        let sakeExecutablePath = packagePath + "/.build/debug/sake"
        XCTAssert(FileManager.default.fileExists(atPath: sakeExecutablePath), "Sake executable not found at \(sakeExecutablePath)")

        let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let sakeAppPath = tempDirectory.appendingPathComponent("my-sake-app").path

        print("Creating SakeApp...")
        let sakeInitResult = SwiftShell.run(bash: "SAKE_APP_PREBUILT_BINARY_PATH= \(sakeExecutablePath) init --sake-app-path \(sakeAppPath)")
        if !sakeInitResult.succeeded {
            XCTFail("Failed to init Sake app: stdout: \(sakeInitResult.stdout), stderr: \(sakeInitResult.stderror)")
        }

        print("Running SakeApp...")
        let sakeRunResult = SwiftShell.run(bash: "SAKE_APP_PREBUILT_BINARY_PATH= \(sakeExecutablePath) hello --sake-app-path \(sakeAppPath)")
        if sakeRunResult.succeeded {
            XCTAssertTrue(sakeRunResult.stdout.contains("Hello, world!"))
        } else {
            XCTFail("Failed to run Sake app: stdout: \(sakeRunResult.stdout), stderr: \(sakeRunResult.stderror)")
        }

        try FileManager.default.removeItem(atPath: tempDirectory.path)
    }
}
