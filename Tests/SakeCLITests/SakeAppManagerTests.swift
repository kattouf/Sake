@testable import SakeCLI
import XCTest

final class SakeAppManagerTests: XCTestCase {
    func testSakeAppInitialization() throws {
        let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(atPath: tempDirectory.path, withIntermediateDirectories: true, attributes: nil)

        let sakeAppManager = SakeAppManager(path: tempDirectory.path)
        try sakeAppManager.initialize()
        try sakeAppManager.run(command: "hello", args: [], caseConvertingStrategy: .keepOriginal)

        try FileManager.default.removeItem(atPath: tempDirectory.path)
    }
}
