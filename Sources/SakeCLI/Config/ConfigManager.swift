import Foundation
import SakeShared

extension ConfigManager {
    enum Error: Swift.Error {
        case configFileNotFound(configPath: String)
        case configFileCorrupted(configPath: String, error: Swift.Error)
    }
}

final class ConfigManager {
    let cliConfig: CLIConfig
    let envConfig: ENVConfig

    init(cliConfig: CLIConfig, envConfig: ENVConfig = .init()) {
        self.cliConfig = cliConfig
        self.envConfig = envConfig
    }

    func resolvedConfig() throws -> Config {
        let configResolver = ConfigResolver()

        if let configPath = cliConfig.configPath ?? envConfig.configPath, !FileManager.default.fileExists(atPath: configPath) {
            throw Error.configFileNotFound(configPath: configPath)
        }
        let fileConfig = try loadFileConfig(path: configResolver.resolveConfigPath(cliConfig: cliConfig, envConfig: envConfig))

        return try configResolver.resolve(
            cliConfig: cliConfig,
            envConfig: envConfig,
            fileConfig: fileConfig
        )
    }

    private func loadFileConfig(path: String) throws -> FileConfig? {
        let fileConfigManager = FileConfigManager(configPath: path)
        do {
            return try fileConfigManager?.load()
        } catch {
            throw Error.configFileCorrupted(configPath: path, error: error)
        }
    }
}

extension ConfigResolver {
    enum Error: Swift.Error, Equatable {
        case mutualExclusiveOptions([String])
    }
}

final class ConfigResolver {
    func resolveConfigPath(cliConfig: CLIConfig, envConfig: ENVConfig) -> String {
        cliConfig.configPath ?? envConfig.configPath ?? Config.default.configPath
    }

    func resolve(cliConfig: CLIConfig, envConfig: ENVConfig, fileConfig: FileConfig?) throws -> Config {
        let sakeAppPath: String? = cliConfig.sakeAppPath ?? envConfig.sakeAppPath ?? fileConfig?.sakeAppPath
        let sakeAppPrebuiltBinaryPath: String? = cliConfig.sakeAppPrebuiltBinaryPath ?? envConfig.sakeAppPrebuiltBinaryPath
            ?? fileConfig?.sakeAppPrebuiltBinaryPath
        let caseConvertingStrategy: CaseConvertingStrategy? = cliConfig.caseConvertingStrategy ?? envConfig.caseConvertingStrategy
            ?? fileConfig?.caseConvertingStrategy

        if sakeAppPath != nil, sakeAppPrebuiltBinaryPath != nil {
            throw Error.mutualExclusiveOptions(["sakeAppPath", "sakeAppPrebuiltBinaryPath"])
        }

        return Config(
            configPath: resolveConfigPath(cliConfig: cliConfig, envConfig: envConfig),
            sakeAppPath: sakeAppPath ?? Config.default.sakeAppPath,
            sakeAppPrebuiltBinaryPath: sakeAppPrebuiltBinaryPath ?? Config.default.sakeAppPrebuiltBinaryPath,
            caseConvertingStrategy: caseConvertingStrategy ?? Config.default.caseConvertingStrategy
        )
    }
}

extension ConfigResolver.Error: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .mutualExclusiveOptions(options):
            "Options are mutually exclusive: \(options.joined(separator: ", "))."
        }
    }
}

extension ConfigManager.Error: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .configFileNotFound(configPath):
            "Configuration file not found at path: \(configPath)."
        case let .configFileCorrupted(configPath, error):
            "Configuration file is corrupted at path: \(configPath). Error: \(error.localizedDescription)."
        }
    }
}
