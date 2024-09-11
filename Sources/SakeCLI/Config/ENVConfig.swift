import Foundation

struct ENVConfig {
    let configPath: String?
    let sakeAppPath: String?

    init() {
        configPath = ProcessInfo.processInfo.environment["SAKE_CONFIG_PATH"]
        sakeAppPath = ProcessInfo.processInfo.environment["SAKE_APP_PATH"]
    }

    private init(configPath: String?, sakeAppPath: String?) {
        self.configPath = configPath
        self.sakeAppPath = sakeAppPath
    }
}

extension ENVConfig {
    static func mock(configPath: String? = nil, sakeAppPath: String? = nil) -> ENVConfig {
        ENVConfig(configPath: configPath, sakeAppPath: sakeAppPath)
    }
}
