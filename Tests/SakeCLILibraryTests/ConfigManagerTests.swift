@testable import SakeCLILibrary
import XCTest

final class ConfigManagerTests: XCTestCase {
    func testConfigManagerShouldThrowErrorIfConfigFileDoesNotExist() {
        let configManager = ConfigManager(cliConfig: .mock(configPath: "notExistedPath"), envConfig: .mock())
        XCTAssertThrowsError(try configManager.resolvedConfig())

        let configManager2 = ConfigManager(cliConfig: .mock(), envConfig: .mock(configPath: "notExistedPath"))
        XCTAssertThrowsError(try configManager2.resolvedConfig())
    }
}
