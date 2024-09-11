import XCTest
@testable import SakeCLI

final class ConfigManagerTests: XCTestCase {
    func testConfigManagerShouldThrowErrorIfConfigFileDoesNotExist() {
        let configManager = ConfigManager(cliConfig: .mock(configPath: "notExistedPath"), envConfig: .mock())
        XCTAssertThrowsError(try configManager.resolvedConfig())
    }
}
