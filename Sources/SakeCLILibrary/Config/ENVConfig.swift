import Foundation
import SakeShared

package struct ENVConfig {
    let configPath: String?
    let sakeAppPath: String?
    let sakeAppPrebuiltBinaryPath: String?
    let caseConvertingStrategy: CaseConvertingStrategy?

    package init() {
        configPath = ProcessInfo.processInfo.environment["SAKE_CONFIG_PATH"]?.nilIfEmpty()
        sakeAppPath = ProcessInfo.processInfo.environment["SAKE_APP_PATH"]?.nilIfEmpty()
        sakeAppPrebuiltBinaryPath = ProcessInfo.processInfo.environment["SAKE_APP_PREBUILT_BINARY_PATH"]?.nilIfEmpty()
        caseConvertingStrategy = ProcessInfo.processInfo.environment["SAKE_CASE_CONVERTING_STRATEGY"]?.nilIfEmpty()
            .flatMap(CaseConvertingStrategy.init(rawValue:))
    }

    private init(
        configPath: String?,
        sakeAppPath: String?,
        sakeAppPrebuiltBinaryPath: String?,
        caseConvertingStrategy: CaseConvertingStrategy?
    ) {
        self.configPath = configPath
        self.sakeAppPath = sakeAppPath
        self.sakeAppPrebuiltBinaryPath = sakeAppPrebuiltBinaryPath
        self.caseConvertingStrategy = caseConvertingStrategy
    }
}

extension ENVConfig {
    static func mock(
        configPath: String? = nil,
        sakeAppPath: String? = nil,
        sakeAppPrebuiltBinaryPath: String? = nil,
        caseConvertingStrategy: CaseConvertingStrategy? = nil
    ) -> ENVConfig {
        ENVConfig(
            configPath: configPath,
            sakeAppPath: sakeAppPath,
            sakeAppPrebuiltBinaryPath: sakeAppPrebuiltBinaryPath,
            caseConvertingStrategy: caseConvertingStrategy,
        )
    }
}
