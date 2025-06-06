import SakeShared
import Subprocess
#if canImport(System)
    import System
#else
    import SystemPackage
#endif
import XCTest

final class IntegrationTests: XCTestCase {
    func testHelloWorld() async throws {
        let packagePath = try XCTUnwrap(URL(fileURLWithPath: #file).findBuildDirectory()?.deletingLastPathComponent().path)

        let sakeExecutablePath = packagePath + "/.build/debug/sake"
        XCTAssert(FileManager.default.fileExists(atPath: sakeExecutablePath), "Sake executable not found at \(sakeExecutablePath)")

        let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let sakeAppPath = tempDirectory.appendingPathComponent("my-sake-app").path

        print("Creating SakeApp...")
        let sakeInitResult = try await Subprocess.run(
            .path(FilePath(sakeExecutablePath)),
            arguments: ["init", "--sake-app-path", sakeAppPath],
            environment: .inherit.updating(["SAKE_APP_PREBUILT_BINARY_PATH": ""]),
            output: .string(limit: 512 * 1024, encoding: UTF8.self),
            error: .string(limit: 512 * 1024, encoding: UTF8.self),
        )
        if !sakeInitResult.terminationStatus.isSuccess {
            XCTFail(
                "Failed to init Sake app: stdout: \(sakeInitResult.standardOutput ?? ""), stderr: \(sakeInitResult.standardError ?? "")",
            )
        }

        print("Running SakeApp...")
        let sakeRunResult = try await Subprocess.run(
            .path(FilePath(sakeExecutablePath)),
            arguments: ["hello", "--sake-app-path", sakeAppPath],
            environment: .inherit.updating(["SAKE_APP_PREBUILT_BINARY_PATH": ""]),
            output: .string(limit: 512 * 1024, encoding: UTF8.self),
            error: .string(limit: 512 * 1024, encoding: UTF8.self),
        )
        if sakeRunResult.terminationStatus.isSuccess {
            XCTAssertTrue(try XCTUnwrap(sakeRunResult.standardOutput).contains("Hello, world!"))
        } else {
            XCTFail("Failed to run Sake app: stdout: \(sakeRunResult.standardOutput ?? ""), stderr: \(sakeRunResult.standardError ?? "")")
        }

        try FileManager.default.removeItem(atPath: tempDirectory.path)
    }
}
