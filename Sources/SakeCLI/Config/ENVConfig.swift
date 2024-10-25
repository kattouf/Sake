import Foundation
import SakeShared

struct ENVConfig {
    let configPath: String?
    let sakeAppPath: String?
    let caseConvertingStrategy: CaseConvertingStrategy?

    init() {
        configPath = ProcessInfo.processInfo.environment["SAKE_CONFIG_PATH"]
        sakeAppPath = ProcessInfo.processInfo.environment["SAKE_APP_PATH"]
        caseConvertingStrategy = ProcessInfo.processInfo.environment["SAKE_CASE_CONVERTING_STRATEGY"]
            .flatMap(CaseConvertingStrategy.init(rawValue:))
    }

    private init(configPath: String?, sakeAppPath: String?, caseConvertingStrategy: CaseConvertingStrategy?) {
        self.configPath = configPath
        self.sakeAppPath = sakeAppPath
        self.caseConvertingStrategy = caseConvertingStrategy
    }
}

extension ENVConfig {
    static func mock(
        configPath: String? = nil,
        sakeAppPath: String? = nil,
        caseConvertingStrategy: CaseConvertingStrategy? = nil
    ) -> ENVConfig {
        ENVConfig(configPath: configPath, sakeAppPath: sakeAppPath, caseConvertingStrategy: caseConvertingStrategy)
    }
}
