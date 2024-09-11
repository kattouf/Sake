@testable import SakeCLI
import XCTest

final class ConfigResolverTests: XCTestCase {
    // MARK: - resolveConfigPath

    func testConfigPathShouldResolvedByDefaultValueIfNothingElsePassed() throws {
        let resolver = ConfigResolver()

        let resolvedConfigPath = resolver.resolveConfigPath(
            cliConfig: .mock(configPath: nil, sakeAppPath: nil, caseConvertingStrategy: nil),
            envConfig: .mock(configPath: nil, sakeAppPath: nil)
        )
        XCTAssertEqual(resolvedConfigPath, Config.default.configPath)
    }

    func testConfigPathShouldResolvedByEnvVarIfPassed() throws {
        let resolver = ConfigResolver()

        let resolvedConfigPath = resolver.resolveConfigPath(
            cliConfig: .mock(configPath: nil, sakeAppPath: nil, caseConvertingStrategy: nil),
            envConfig: .mock(configPath: "env-sourced-path", sakeAppPath: nil)
        )
        XCTAssertEqual(resolvedConfigPath, "env-sourced-path")
    }

    func testConfigPathShouldResolvedByCliIfPassed() throws {
        let resolver = ConfigResolver()

        let resolvedConfigPath = resolver.resolveConfigPath(
            cliConfig: .mock(configPath: "cli-sourced-path", sakeAppPath: nil, caseConvertingStrategy: nil),
            envConfig: .mock(configPath: nil, sakeAppPath: nil)
        )
        XCTAssertEqual(resolvedConfigPath, "cli-sourced-path")
    }

    func testConfigPathShouldResolvedByCliIfPassedEvenIfEnvVarIsPassed() throws {
        let resolver = ConfigResolver()

        let resolvedConfigPath = resolver.resolveConfigPath(
            cliConfig: .mock(configPath: "cli-sourced-path", sakeAppPath: nil, caseConvertingStrategy: nil),
            envConfig: .mock(configPath: "env-sourced-path", sakeAppPath: nil)
        )
        XCTAssertEqual(resolvedConfigPath, "cli-sourced-path")
    }

    // MARK: - resolve

    func testConfigShouldResolvedByDefaultValueIfNothingElsePassed() throws {
        let resolver = ConfigResolver()

        let resolvedConfig = resolver.resolve(
            cliConfig: .mock(configPath: nil, sakeAppPath: nil, caseConvertingStrategy: nil),
            envConfig: .mock(configPath: nil, sakeAppPath: nil),
            fileConfig: nil
        )
        XCTAssertEqual(resolvedConfig.configPath, Config.default.configPath)
        XCTAssertEqual(resolvedConfig.sakeAppPath, Config.default.sakeAppPath)
        XCTAssertEqual(resolvedConfig.caseConvertingStrategy, Config.default.caseConvertingStrategy)
    }

    func testConfigShouldResolvedByEnvVarIfPassed() throws {
        let resolver = ConfigResolver()

        let resolvedConfig = resolver.resolve(
            cliConfig: .mock(configPath: nil, sakeAppPath: nil, caseConvertingStrategy: nil),
            envConfig: .mock(configPath: "env-sourced-path", sakeAppPath: "env-sourced-path-2"),
            fileConfig: nil
        )
        XCTAssertEqual(resolvedConfig.configPath, "env-sourced-path")
        XCTAssertEqual(resolvedConfig.sakeAppPath, "env-sourced-path-2")
        XCTAssertEqual(resolvedConfig.caseConvertingStrategy, Config.default.caseConvertingStrategy)
    }

    func testConfigShouldResolvedByCliIfPassed() throws {
        let resolver = ConfigResolver()

        let resolvedConfig = resolver.resolve(
            cliConfig: .mock(configPath: "cli-sourced-path", sakeAppPath: "cli-sourced-path-2", caseConvertingStrategy: nil),
            envConfig: .mock(configPath: nil, sakeAppPath: nil),
            fileConfig: nil
        )
        XCTAssertEqual(resolvedConfig.configPath, "cli-sourced-path")
        XCTAssertEqual(resolvedConfig.sakeAppPath, "cli-sourced-path-2")
        XCTAssertEqual(resolvedConfig.caseConvertingStrategy, Config.default.caseConvertingStrategy)
    }

    func testConfigShouldResolvedByFileConfigIfPassed() throws {
        let resolver = ConfigResolver()

        let resolvedConfig = resolver.resolve(
            cliConfig: .mock(configPath: nil, sakeAppPath: nil, caseConvertingStrategy: nil),
            envConfig: .mock(configPath: nil, sakeAppPath: nil),
            fileConfig: .mock(sakeAppPath: "file-sourced-path", caseConvertingStrategy: nil)
        )
        XCTAssertEqual(resolvedConfig.configPath, Config.default.configPath)
        XCTAssertEqual(resolvedConfig.sakeAppPath, "file-sourced-path")
        XCTAssertEqual(resolvedConfig.caseConvertingStrategy, Config.default.caseConvertingStrategy)
    }

    func testConfigShouldResolvedByCliIfPassedEvenIfEnvVarIsPassed() throws {
        let resolver = ConfigResolver()

        let resolvedConfig = resolver.resolve(
            cliConfig: .mock(configPath: "cli-sourced-path", sakeAppPath: "cli-sourced-path-2", caseConvertingStrategy: nil),
            envConfig: .mock(configPath: "env-sourced-path", sakeAppPath: "env-sourced-path-2"),
            fileConfig: nil
        )
        XCTAssertEqual(resolvedConfig.configPath, "cli-sourced-path")
        XCTAssertEqual(resolvedConfig.sakeAppPath, "cli-sourced-path-2")
        XCTAssertEqual(resolvedConfig.caseConvertingStrategy, Config.default.caseConvertingStrategy)
    }

    func testConfigShouldResolvedByCliIfFileConfigIsPassed() throws {
        let resolver = ConfigResolver()

        let resolvedConfig = resolver.resolve(
            cliConfig: .mock(configPath: "cli-sourced-path", sakeAppPath: "cli-sourced-path-2", caseConvertingStrategy: nil),
            envConfig: .mock(configPath: nil, sakeAppPath: nil),
            fileConfig: .mock(sakeAppPath: "file-sourced-path", caseConvertingStrategy: nil)
        )
        XCTAssertEqual(resolvedConfig.configPath, "cli-sourced-path")
        XCTAssertEqual(resolvedConfig.sakeAppPath, "cli-sourced-path-2")
        XCTAssertEqual(resolvedConfig.caseConvertingStrategy, Config.default.caseConvertingStrategy)
    }

    func testConfigShouldResolvedByEnvVarIfFileConfigIsPassed() throws {
        let resolver = ConfigResolver()

        let resolvedConfig = resolver.resolve(
            cliConfig: .mock(configPath: nil, sakeAppPath: nil, caseConvertingStrategy: nil),
            envConfig: .mock(configPath: "env-sourced-path", sakeAppPath: "env-sourced-path-2"),
            fileConfig: .mock(sakeAppPath: "file-sourced-path", caseConvertingStrategy: nil)
        )
        XCTAssertEqual(resolvedConfig.configPath, "env-sourced-path")
        XCTAssertEqual(resolvedConfig.sakeAppPath, "env-sourced-path-2")
        XCTAssertEqual(resolvedConfig.caseConvertingStrategy, Config.default.caseConvertingStrategy)
    }

    func testConfigShouldResolvedByFileConfigIfCliAndEnvVarArePassed() throws {
        let resolver = ConfigResolver()

        let resolvedConfig = resolver.resolve(
            cliConfig: .mock(configPath: "cli-sourced-path", sakeAppPath: "cli-sourced-path-2", caseConvertingStrategy: nil),
            envConfig: .mock(configPath: "env-sourced-path", sakeAppPath: "env-sourced-path-2"),
            fileConfig: .mock(sakeAppPath: "file-sourced-path", caseConvertingStrategy: nil)
        )
        XCTAssertEqual(resolvedConfig.configPath, "cli-sourced-path")
        XCTAssertEqual(resolvedConfig.sakeAppPath, "cli-sourced-path-2")
        XCTAssertEqual(resolvedConfig.caseConvertingStrategy, Config.default.caseConvertingStrategy)
    }
}
