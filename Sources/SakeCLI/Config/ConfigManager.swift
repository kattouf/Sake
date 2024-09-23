import Foundation

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

        return configResolver.resolve(
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

final class ConfigResolver {
    func resolveConfigPath(cliConfig: CLIConfig, envConfig: ENVConfig) -> String {
        cliConfig.configPath ?? envConfig.configPath ?? Config.default.configPath
    }

    func resolve(cliConfig: CLIConfig, envConfig: ENVConfig, fileConfig: FileConfig?) -> Config {
        Config(
            configPath: resolveConfigPath(cliConfig: cliConfig, envConfig: envConfig),
            sakeAppPath: cliConfig.sakeAppPath ?? envConfig.sakeAppPath ?? fileConfig?.sakeAppPath ?? Config.default.sakeAppPath,
            caseConvertingStrategy: cliConfig.caseConvertingStrategy ?? fileConfig?.caseConvertingStrategy
                ?? Config.default.caseConvertingStrategy
        )
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
